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
    (new Availability(instance: @instance, group: @group)).appendTo @container
    @container.on "scroll", @scroll

    $(window).on "resize", @resize

    @on "release", =>
      $(window).off "resize", @resize


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
    @el.
      transition({ y: 0, height: @_source.outerHeight() }).
      transition(opacity: 0).
      queue(@hidden)

  hidden: =>
    @trigger "hidden"
    @el.remove()
    @release()

  resize: =>
    @_scrollOffset = @header.outerHeight() - @$(".tabs").outerHeight()

  scroll: =>
    top = Math.max(@container.scrollTop() - @_scrollOffset, 0)
    @header.
      toggleClass("floating", !!top).
      css(transform: "translateY(#{top}px)")

  switchTabs: (e) ->
    tab = $(e.target).closest("a").attr("rel")
    @$(".#{tab}").addClass("active").siblings().removeClass("active")


class Availability extends Spine.Controller
  tag: "section"

  elements:
    "[rel=mode] .dropdown-toggle": "modeSelector"
    "[type=search]": "searchBox"

  events:
    "tap .avatar": "toggleAvailability"
    "click [rel=mode] .dropdown-menu": "changeView"
    "input [type=search]": "filter"

  init: ->
    @el.addClass("availability")
    @html @view("events/availability")(instance: @instance, group: @group)

  toggleAvailability: (e) ->
    if @el.hasClass("show-all")
      li = $(e.target).closest("li")
      if li.hasClass("available")
        li.addClass("unavailable").removeClass("available")
      else if li.hasClass("unavailable")
        li.removeClass("unavailable")
      else
        li.addClass("available")

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

  # down: (e) =>
  #   source = $(e.target).closest(".avatar")
  #   offset = source.offset()
  #   origin = @eventPosition(e)
  #
  #   @drag =
  #     origin: origin
  #     item: source
  #     timer: setTimeout (=> @move(e, true)), 500
  #     offset:
  #       x: origin.x - offset.left
  #       y: origin.y - offset.top
  #   $(document).
  #     on("mousemove", @move).
  #     on("touchmove", @move).
  #     on("mouseup", @up).
  #     on("touchend", @up)
  #
  # move: (e, force = false) =>
  #   clearTimeout @drag.timer
  #   position = @eventPosition(e)
  #   unless @drag.dragging
  #     dx = position.x - @drag.origin.x
  #     dy = position.y - @drag.origin.y
  #     if force || Math.sqrt(dx * dx + dy * dy) > 5
  #       @drag.dragging = true
  #       @drag.helper = @drag.item.clone().appendTo("body").
  #         addClass("drag-helper").
  #         css(transformOrigin: "#{@drag.offset.x}px #{@drag.offset.y}px")
  #       setTimeout =>
  #         @drag.helper.addClass("dragging")
  #       , 100
  #
  #   if @drag.dragging
  #     e.preventDefault()
  #     @drag.helper.css
  #       left: position.x - @drag.offset.x
  #       top: position.y - @drag.offset.y
  #
  # up: (e) =>
  #   if @drag.dragging
  #     e.preventDefault()
  #     @drag.helper.
  #       transition({ transform: "scale(0)" }, 125, "ease-in").
  #       queue =>
  #         @drag.helper.remove()
  #
  #   clearTimeout @drag.timer
  #   $(document).
  #     off("mousemove", @move).
  #     off("touchmove", @move).
  #     off("mouseup", @up).
  #     off("touchend", @up)
  #
  # eventPosition: (e) ->
  #   position = if e.originalEvent.targetTouches?.length
  #     e.originalEvent.targetTouches[0]
  #   else
  #     e
  #   { x: position.pageX, y: position.pageY }
