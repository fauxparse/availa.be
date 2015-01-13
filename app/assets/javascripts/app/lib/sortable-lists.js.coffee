class SortableList extends Spine.Controller
  SCROLL_SENSITIVITY: 40
  SCROLL_TIMER: 100
  SCROLL_AMOUNT: 20

  down: (e) =>
    e.preventDefault()
    top = @el.offset().top - @el.scrollTop()

    @$(".sortable").each (i, el) ->
      $el = $(el)
      h = $el.outerHeight(true)
      y = $el.offset().top - top
      $el.data height: h, offset: y, y: y

    item = $(e.target).closest(".sortable").addClass("sorting")

    @drag =
      offset: top
      item: item
      items: ($(item) for item in @$(".sortable").get())
      origin: @eventPosition(e) + @scrollParent().scrollTop()

    $(document).
      on("mousemove touchmove", @move).
      on("mouseup touchend", @up)

    @move(e)

  move: (e, animate = false) =>
    @checkScrollBounds(e)

    e.preventDefault()
    y = @eventPosition(e) - @drag.origin + @scrollParent().scrollTop()
    @drag.item.data(y: @drag.item.data("offset") + y)

    css = { transform: "translateY(#{y}px)" }
    if animate
      @drag.item.transition css, @SCROLL_TIMER, "linear"
    else
      @drag.item.css css

    @sortItems()

  up: (e) =>
    e.preventDefault()
    @$(".sortable").removeClass("sorting").css(transform: "translateY(0)")
    for item in @drag.items
      item.appendTo(@el)
    $(document).
      off("mousemove touchmove", @move).
      off("mouseup touchend", @up)
    @el.trigger("sorted")

    delete @drag
    delete @_scrollParent

  eventPosition: (e) ->
    if e.originalEvent.targetTouches?.length
      e.originalEvent.targetTouches[0].pageY
    else
      e.pageY

  sortItems: ->
    @drag.items.sort (a, b) ->
      a.data("y") - b.data("y")
    y = 0
    for item in @drag.items
      dy = y - item.data("offset")
      unless item.hasClass("sorting")
        item.
          data(y: y).
          css(transform: "translateY(#{dy}px)")
      y += item.data("height")

  checkScrollBounds: (e) ->
    y = @eventPosition(e)

    if y - @SCROLL_SENSITIVITY < @_scrollUpper
      unless @_direction == -1
        clearInterval @_scroller
        @_scroller = setInterval @autoscroll(-@SCROLL_AMOUNT, e), @SCROLL_TIMER
        @_direction = -1
    else if y + @SCROLL_SENSITIVITY > @_scrollLower
      unless @_direction == 1
        clearInterval @_scroller
        @_scroller = setInterval @autoscroll(@SCROLL_AMOUNT, e), @SCROLL_TIMER
        @_direction = 1
    else
      clearInterval @_scroller if @_direction
      @_direction = 0

  autoscroll: (direction, event) ->
    =>
      y = if direction < 0
        Math.max(@scrollParent().scrollTop() + direction, 0)
      else
        max = @scrollParent()[0].scrollHeight - (@_scrollLower - @_scrollUpper)
        Math.min(@scrollParent().scrollTop() + direction, max)
      @scrollParent().animate { scrollTop: y }, @SCROLL_TIMER, "linear"
      @move event, true

  scrollParent: ->
    unless @_scrollParent
      excludeStaticParent = @el.css("position") == "absolute"
      @_scrollParent = @el.add(@el.parents()).filter ->
        parent = $(this)
        if excludeStaticParent && parent.css("position") == "static"
          false
        else
          css = parent.css("overflow") + parent.css("overflow-y")
          /(auto|scroll)/.test(css)
      .eq(0)

      offset = @_scrollParent.offset()
      @_scrollUpper = offset.top
      @_scrollLower = offset.top + @_scrollParent.height()
    @_scrollParent

$(document)
  .on "mousedown touchstart", ".sortable-list [rel=reorder]", (e) ->
    list = $(e.target).closest(".sortable-list")
    unless manager = list.data("sortable")
      manager = new SortableList(el: list)
      list.data "sortable", manager
    manager.down e
  .on "click tap", ".sortable-list [rel=reorder]", (e) ->
    e.preventDefault()
