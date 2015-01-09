#= require ../events

class App.Events.Calendar extends App.Section.Page
  rowHeight: 64
  headerHeight: 24

  events:
    "touchstart": "touchStart"
    "mousedown": "touchStart"
    "mousewheel": "mouseWheel"
    "tap .day": "dayTapped"

  init: ->
    super
    @el.addClass("calendar")
    @title I18n.t("events.calendar.title")
    @dates = $("<div>").addClass("dates").appendTo(@content)

    $("<a>", href: "/events/new", html: "<i class=\"icon-add\"></i>").
      addClass("button floating-action-button").
      appendTo(@footer)

    @startDate = moment().startOf("week")
    @endDate = @startDate.clone()
    @startY = @endY = @offset = 0

    $(window).on "resize", @resize
    @on "release", => $(window).off "resize", @resize

    setTimeout =>
      @resize()
    , 100

  activate: ->
    super
    @resize()

  resize: =>
    @height = @el.height()
    @fill()

  fill: =>
    @today = moment()
    @fillForwards()
    @fillBackwards()

  fillForwards: ->
    while @endY - @offset < @height
      for week in @createWeeks(@endDate)
        week.appendTo(@dates).data("y", @endY).css(top: @endY)
        @endY += @rowHeight
        @endY += @headerHeight if week.hasClass("start-of-month")
      @endDate.add(1, "week")

  fillBackwards: ->
    while @offset - @startY < @height
      @startDate.subtract(1, "week")
      for week in @createWeeks(@startDate).reverse()
        week.prependTo(@dates)
        @startY -= @rowHeight
        @startY -= @headerHeight if week.hasClass("start-of-month")
        week.data("y", @startY).css(top: @startY)

  createWeeks: (date) ->
    endDate = date.clone().endOf("week")
    if endDate.isSame(date, "month")
      [@createWeek(date, endDate)]
    else
      [
        @createWeek(date, date.clone().endOf("month")),
        @createWeek(endDate.clone().startOf("month"), endDate)
      ]

  createWeek: (startDate, endDate) ->
    isStart = startDate.date() == 1
    isEnd = !endDate.isSame(startDate.clone().endOf("week"), "month")
    week = $("<section>").addClass("week")
      .toggleClass("start-of-month", isStart)
      .toggleClass("end-of-month", isEnd)

    i = 0
    d = startDate.clone()
    while i < 7 and !d.isAfter(endDate)
      week.append @createDay(d)
      d.add(1, "day")
      i++
    week

  createDay: (date) ->
    day = $("<article>")
      .addClass("day")
      .attr("date", date.format())
      .attr("day", date.day())
      .data(date: date)
      .toggleClass("today", date.isSame(@today, "day"))
    if date.date() == 1
      day.attr "month-start", date.format("MMMM YYYY")
    day.append $("<b>", text: date.date())

  touchStart: (e) ->
    e.stopPropagation()

    @reference = @yPosition(e)
    @velocity = @amplitude = 0
    @frame = @target = @offset = Math.round(@offset)
    @scroll(@offset)
    @timestamp = Date.now()
    @ticker = setTimeout(@track, 100)

    $(window)
      .on("touchmove", @touchMove)
      .on("mousemove", @touchMove)
      .on("touchend", @touchEnd)
      .on("mouseup", @touchEnd)

  touchMove: (e) =>
    e.preventDefault()
    y = @yPosition(e)
    delta = @reference - y
    if delta > 2 || delta < -2
      @reference = y
      @scroll @offset + delta

  touchEnd: (e) =>
    clearTimeout(@ticker)
    $(window)
      .off("touchmove", @touchMove)
      .off("mousemove", @touchMove)
      .off("touchend", @touchEnd)
      .off("mouseup", @touchEnd)

    if @velocity > 10 || @velocity < -10
      @amplitude = 0.8 * @velocity
      @target = Math.round(@offset + @amplitude)
      @timestamp = Date.now()
      requestAnimationFrame(@autoScroll)

  mouseWheel: (e) ->
    @amplitude = 0
    @scroll Math.round(@offset - e.deltaY * e.deltaFactor)

  yPosition: (e) ->
    if e.originalEvent.targetTouches?.length
      e.originalEvent.targetTouches[0].pageY
    else
      e.pageY

  scroll: (offset) ->
    @offset = offset
    @dates.css $.support.transform, "translateY(#{-@offset}px)"
    setTimeout @fill, 0

  track: =>
    now = Date.now()
    elapsed = now - @timestamp
    @timestamp = now
    delta = @offset - @frame
    @frame = @offset
    v = 1000 * delta / (1 + elapsed)
    @velocity = 0.8 * v + 0.2 * @velocity
    @ticker = setTimeout(@track, 100)

  autoScroll: =>
    if @amplitude
      elapsed = Date.now() - @timestamp
      delta = -@amplitude * Math.exp(-elapsed / 325)
      if delta > 0.5 || delta < -0.5
        @scroll @target + delta
        requestAnimationFrame @autoScroll
      else
        @scroll Math.round(@target)

  dayTapped: (e) ->
    date = moment($(e.target).closest("day").attr("date"))
    # console.log date
