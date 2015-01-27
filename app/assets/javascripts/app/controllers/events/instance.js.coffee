#= require ../events

class App.Events.Instance extends Spine.Controller
  elements:
    ".container > header": "header"
    ".container": "container"

  events:
    "tap [rel=back]": "hide"
    "tap header .tabs a": "switchTabs"
    "flick .list-item:not(.open)": "openItem"
    "flick .list-item.open .avatar": "closeItem"
    "tap .list-item.open .avatar": "closeItem"

  init: ->
    @el.addClass "event-instance"
    @group = @instance.event().group()

    @html @view("events/instance")(instance: @instance, group: @group)

    @controllers =
      assignments: Assignments
      availability: Availability

    for own key, klass of @controllers
      (@[key] = new klass(instance: @instance, group: @group))
        .appendTo @container
    @container.on "scroll", @scroll

    @$(".assignments")
      .add(@$("[rel=assignments]").parent())
      .addClass("active")

    $(window).on "resize", @resize

    @on "release", =>
      $(window).off "resize", @resize

  release: =>
    for own key of @controllers
      @[key].release()
    super

  showFrom: (source) ->
    @_source = source
    @appendTo("section.main")

    top = @_source.offset().top

    @el.css
      top: top
      height: @_source.outerHeight()
      opacity: 0
    @el.transition(
      { y: -top, height: "100%", opacity: 1 }
      { duration: 500, easing: "easeOutCubic" }
    ).queue @shown

  shown: =>
    @resize()
    @trigger "shown"
    @el.stop(true)

  hide: (e) ->
    e?.preventDefault()
    @el
      .transition({ y: 0, height: @_source.outerHeight() })
      .transition(opacity: 0)
      .queue(@hidden)

  hidden: =>
    @trigger "hidden"
    @el.remove()
    @release()

  resize: =>
    @_scrollOffset = @header.outerHeight() - @$(".tabs").outerHeight()

  scroll: =>
    top = Math.max(@container.scrollTop() - @_scrollOffset, 0)
    @header
      .toggleClass("floating", !!top)
      .css(transform: "translateY(#{top}px)")

  switchTabs: (e) ->
    tab = $(e.target).closest("a").attr("rel")
    @$(".#{tab}").addClass("active").siblings().removeClass("active")

  openItem: (e) ->
    $(e.target).closest(".list-item").addClass("open").trigger("open")
      .siblings(".open").trigger("close").removeClass("open").end()

  closeItem: (e) ->
    $(e.target).closest(".list-item").removeClass("open").trigger("close")

class Assignments extends Spine.Controller
  tag: "section"

  events:
    "tap .toggle": "toggle"
    "tap .show-all .avatar": "toggleAssignment"

  init: ->
    @el.addClass("assignments")
    @html @view("events/assignments")(instance: @instance, group: @group)
    @update()
    @instance.on "change", @changed

  release: =>
    @instance.off "change", @changed
    super

  changed: =>
    @update()
    clearTimeout @_saveTimer
    @_saveTimer = setTimeout @save, 2000

  save: =>
    @instance.event().save()

  update: =>
    @$(".member").removeClass("available")
    for own roleId, members of @instance.availabilityByRole()
      for member in members
        @$("[role-id=#{roleId}] [member-id=#{member.id}]").addClass("available")
      @$("[role-id=#{roleId}]").toggleClass("empty", !members.length)

    @$(".member").removeClass("assigned")
    for own roleId, memberIds of @instance.assignments()
      for id in memberIds
        @$("[role-id=#{roleId}] [member-id=#{id}]").addClass("assigned")

  toggle: (e) ->
    @$(e.target).closest("section").toggleClass("show-all")

  toggleAssignment: (e) ->
    li = $(e.target).closest("li")
    member = @group.members().find li.attr("member-id")
    roleId = li.closest("section").attr("role-id")
    @instance.assign member, roleId

class Availability extends Spine.Controller
  tag: "section"

  elements:
    "[rel=mode] .dropdown-toggle": "modeSelector"
    "[type=search]": "searchBox"

  events:
    "tap .avatar": "toggleAvailability"
    "click [rel=mode] .dropdown-menu": "changeView"
    "input [type=search]": "filter"
    "open [member-id]": "openItem"

  init: ->
    @el.addClass("availability")
    @html @view("events/availability")(instance: @instance, group: @group)
    @update()
    @instance.on "change", @changed

  release: =>
    @instance.off "change", @changed
    super

  changed: =>
    @update()

  update: ->
    @$(".list-item").removeClass("available unavailable")
    for own id, available of @instance.availability()
      @$("[member-id=#{id}]")
        .toggleClass("available", available == true)
        .toggleClass("unavailable", available == false)

  toggleAvailability: (e) ->
    if @el.hasClass("show-all")
      li = $(e.target).closest("li")
      member = @group.members().find(li.attr("member-id"))
      if li.hasClass("available")
        @instance.setAvailability member, false
      else if li.hasClass("unavailable")
        @instance.setAvailability member, undefined
      else
        @instance.setAvailability member, true

  changeView: (e) ->
    mode = $(e.target).attr("rel")
    @el.toggleClass "show-all", mode == "all"
    @modeSelector.text I18n.t("events.instance.availability.#{mode}")

  filter: ->
    clearTimeout @_filter
    setTimeout @doFilter, 100

  doFilter: =>
    if filter = @searchBox.val()
      @$(".list-item").addClass("hidden")
      for member in @group.members().matching @searchBox.val()
        @$(".list-item[member-id=#{member.id}]").removeClass("hidden")
    else
      @$(".list-item").removeClass("hidden")

  openItem: (e) ->
    item = $(e.target).closest(".list-item")
    unless item.has(".menu").length
      menu = $("<div>", class: "menu").appendTo(item)
