#= require ../events

class App.Events.Instance extends Spine.Controller
  elements:
    ".container > header": "header"
    ".container": "container"

  events:
    "tap [rel=back]": "hide"
    "tap header .tabs a": "switchTabs"
    "flick,drag .availability .list-item:not(.open)": "openItem"
    "flick,tap .availability .list-item.open .avatar": "closeItem"

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
    e.preventDefault()
    $(e.target).closest(".list-item").addClass("open").trigger("open")
      .siblings(".open").trigger("close").removeClass("open").end()

  closeItem: (e) ->
    e.preventDefault()
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

  update: =>
    assigned = {}
    available = {}

    @$(".available").removeClass("available")
    for own roleId, members of @instance.availabilityByRole()
      for member in members
        @$("[role-id=#{roleId}] [member-id=#{member.id}]").addClass("available")
        available[roleId] = (available[roleId] || 0) + 1

    @$(".assigned").removeClass("assigned")
    for own roleId, memberIds of @instance.assignments()
      for id in memberIds
        @$("[role-id=#{roleId}] [member-id=#{id}]").addClass("assigned")
        assigned[roleId] = (assigned[roleId] || 0) + 1

    for role in @instance.event().roles().all()
      empty = !assigned[role.id] && !available[role.id]
      m = assigned[role.id] || 0
      n = role.range()
      @$("[role-id=#{role.id}]")
        .toggleClass("empty", empty)
        .toggleClass("invalid", !role.validNumber(m))
        .find("small[rel=role]")
        .text(I18n.t("events.instance.assignments.m_of_n", {m, n}))

  toggle: (e) ->
    @$(e.target).closest("section").toggleClass("show-all")

  toggleAssignment: (e) ->
    li = $(e.target).closest("li")
    member = @group.members().find li.attr("member-id")
    roleId = li.closest("section").attr("role-id")
    if @instance.assigned member, roleId
      @instance.unassign member, roleId
    else
      @instance.assign member, roleId

class Availability extends Spine.Controller
  tag: "section"

  elements:
    "[rel=mode] .dropdown-toggle": "modeSelector"
    "[type=search]": "searchBox"

  events:
    "tap .member:not(.open) .avatar": "toggleAvailability"
    "click [rel=mode] .dropdown-menu": "changeView"
    "input [type=search]": "filter"
    "open [member-id]": "openItem"
    "tap [member-id] button": "assignRole"

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
    @toggleEmpty()

  toggleEmpty: ->
    visible = if @el.hasClass("show-all")
      @$(".member:not(.hidden)")
    else
      @$(".member.available:not(.hidden)")
    @$(".empty").toggleClass("hidden", !!visible.length)

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
    @toggleEmpty()

  changeView: (e) ->
    mode = $(e.target).attr("rel")
    @el.toggleClass "show-all", mode == "all"
    @modeSelector.text I18n.t("events.instance.availability.#{mode}")
    @toggleEmpty()

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
    @toggleEmpty()

  openItem: (e) ->
    item = $(e.target).closest(".list-item")
    menu = item.find(".menu")
    member = @group.members().find(item.attr("member-id"))
    unless menu.length
      menu = $("<div>", class: "menu").appendTo(item)
      for role in @instance.event().roles().forMember(member)
        $("<button>", "role-id": role.id, text: role.name())
          .appendTo(menu)
    menu.find("button").each (i, el) =>
      button = $(el)
      role = button.attr("role-id")
      button.toggleClass("active", @instance.assigned(member, role))

  assignRole: (e) ->
    button = $(e.target).closest("[role-id]")
    item = button.closest(".list-item")
    member = @group.members().find(item.attr("member-id"))
    role = button.attr("role-id")
    if button.hasClass("active")
      button.removeClass("active")
      @instance.unassign(member, role)
    else
      button.addClass("active")
      @instance.assign(member, role)
    item.removeClass("open")
