class SortableList extends Spine.Controller
  down: (e) =>
    e.preventDefault()
    top = @el.offset().top
    @$(".sortable").each (i, el) ->
      $el = $(el)
      offset = $el.offset().top
      h = $el.outerHeight(true)
      y = offset - top
      $el.data height: h, offset: y, y: y
    @drag =
      offset: top
      item: $(e.target).closest(".sortable").addClass("sorting")
      items: ($(item) for item in @$(".sortable").get())
      origin: @eventPosition(e)
    $(document).
      on("mousemove touchmove", @move).
      on("mouseup touchend", @up)

    @move(e)

  move: (e) =>
    # TODO: auto-scroll parent region
    y = @eventPosition(e) - @drag.origin
    @drag.item.
      css(transform: "translateY(#{y}px)").
      data(y: @drag.item.data("offset") + y)
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

  eventPosition: (e) ->
    if e.originalEvent.targetTouches?.length
      e.originalEvent.targetTouches[0].pageY
    else
      e.pageY

  sortItems: ->
    @drag.items.sort (a, b) =>
      a.data("y") - b.data("y")
    y = 0
    for item in @drag.items
      dy = y - item.data("offset")
      unless item.hasClass("sorting")
        item.
          data(y: y).
          css(transform: "translateY(#{dy}px)")
      y += item.data("height")

$(document)
  .on "mousedown touchstart", ".sortable-list [rel=reorder]", (e) ->
    list = $(e.target).closest(".sortable-list")
    unless manager = list.data("sortable")
      manager = new SortableList(el: list)
      list.data "sortable", manager
    manager.down e
  .on "click tap", ".sortable-list [rel=reorder]", (e) ->
    e.preventDefault()
