#= require ../events

class App.Events.Instance extends Spine.Controller
  elements:
    ".container > header": "header"
    ".container": "container"

  events:
    "tap [rel=back]": "hide"
    "tap header .tabs a": "switchTabs"

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

class Assignments extends Spine.Controller
  tag: "section"

  events:
    "tap .toggle": "toggle"
    "tap .show-all .avatar": "toggleAssignment"

  init: ->
    @el.addClass("assignments")
    @html @view("events/assignments")(instance: @instance, group: @group)
    @update()
    @instance.on "change", @update

  release: =>
    @instance.off "change", @update
    super

  update: =>
    @$(".member").removeClass("available")
    for own roleId, members of @instance.availability()
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
    "mousedown .avatar": "down"
    "touchstart .avatar": "down"

  init: ->
    @el.addClass("availability")
    @html @view("events/availability")(instance: @instance, group: @group)

  toggleAvailability: (e) ->
    if @el.hasClass("show-all")
      li = $(e.target).closest("li")
      member = @group.members().find(li.attr("member-id"))
      if li.hasClass("available")
        li.addClass("unavailable").removeClass("available")
        @instance.setAvailability member, false
      else if li.hasClass("unavailable")
        li.removeClass("unavailable")
        @instance.setAvailability member, undefined
      else
        li.addClass("available")
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

  down: (e) ->
    @_touchTimer = setTimeout (=> @openMenu(e)), $.Finger.pressDuration
    $(document).on "mouseup touchend", @up

  up: =>
    clearTimeout @_touchTimer
    $(document).off "mouseup touchend", @up

  openMenu: (e) ->
    avatar = $(e.target).closest(".avatar")
    offset = avatar.offset()
    menu =
      x: offset.left + avatar.width() / 2
      y: offset.top + avatar.height() / 2
      items: @instance.event().roles()

    if menu.x < @el.width() / 3
      menu.end = 180
    else
      menu.start = 180
      menu.direction = -1
    if menu.items.length > 4
      menu.items.splice(3, menu.items.length, "...")

    member = @group.members()
      .find(avatar.closest("[member-id]").attr("member-id"))

    new RadialMenu(menu)
      .on "render", (role, div, index) ->
        if role == "..."
          div.html "<i class=\"icon-more-horiz\"></i>"
      .on "select", (role) =>
        unless role == "..."
          @instance.assign member, role

class RadialMenu extends Spine.Controller
  init: ->
    @start ||= 0
    @end ||= 360
    @size ||= 100
    @radius ||= @size
    @direction ||= 1

    @el
      .addClass("radial-menu")
      .appendTo("body")
      .css(left: @x, top: @y)

    @delay @open

    $(document)
      .on("mousemove touchmove", @move)
      .on("mouseup touchend", @close)

  open: =>
    theta = (@end - @start) * Math.PI / 360 / @items.length
    max = 2 * @radius * Math.sin(theta)
    @scale = Math.min(1.0, max / @size)

    for item, index in @items
      theta = (index + 0.5) * (@end - @start) / @items.length
      if @direction < 0
        theta = @end - theta
      else
        theta = @start + theta
      theta *= Math.PI / 180
      r = @radius
      div = @render(item, index).appendTo(@el)
      @trigger "render", item, div, index
      div.transition({
        x: r * Math.sin(theta),
        y: -r * Math.cos(theta),
        scale: @scale * 0.95,
        opacity: 0.875
      }, {
        duration: 250,
        easing: 'easeOutBack',
        delay: index * 50
      })

  close: =>
    $(document)
      .off("mousemove touchmove", @move)
      .off("mouseup touchend", @close)
    @el.children().not(".over")
      .transition { x: 0, y: 0, scale: 0.1, opacity: 0 },
        duration: 250,
        easing: "out"
    @el.children(".over")
      .transition({ scale: 5, opacity: 0 }, { duration: 250, easing: "in" })
      .each (i, el) =>
        @trigger "select", $(el).data("item")
    setTimeout @release, 500

  render: (item, index) ->
    div = $("<div>")
      .addClass("radial-menu-item")
      .data("item", item)
      .append($("<span>", text: item.toString()))
      .css(width: @size, height: @size, margin: @size / -2)

  move: (e) =>
    e.preventDefault()
    position = if e.originalEvent.targetTouches?.length
      e.originalEvent.targetTouches[0]
    else
      e
    item = @getItemAt(position.pageX, position.pageY)
    if item
      if !item.hasClass("over")
        item.addClass("over").siblings(".over").removeClass("over")
    else
      @$(".over").removeClass("over")

  getItemAt: (x, y) ->
    for element in @el.children().get()
      element = $(element)
      [w, h] = [element.width(), element.height()]
      offset = element.offset()
      if offset.left <= x < (offset.left + w)
        if offset.top <= y < (offset.top + h)
          dx = x - (offset.left + w / 2)
          dy = y - (offset.top + h / 2)
          if Math.sqrt(dx * dx + dy * dy) < (w / 2) * 0.95
            return element
    undefined
