#= require ./dialog

class App.DateEditor extends App.Dialog
  elements:
    ".months": "months"
    "header": "header"

  events:
    "tap [rel=prev]": "prev"
    "tap [rel=next]": "next"
    "tap .date": "choose"
    "tap [rel=ok]": "ok"
    "flick": "flick"

  init: ->
    @input = @parent?.find("[rel=date]") || $([])
    @date ||= moment(@input.val())
    @input.val(@date.format())
    @toggle = @parent?.find("[data-toggle=date]") || $([])
    @toggle.text @date.format('ll')
    super
    @el.addClass("select-date")

  render: ->
    @html @view("date/date")(date: @date)
    @months.append @renderMonth(@date)

  renderMonth: (date = @date) ->
    $(@view("date/month")({
      date: date, weekStart: moment().startOf("week").day()
    }))

  updateHeader: (date = @date) ->
    @header.
      find(".day").text(date.format("dddd")).end().
      find(".date").text(date.format("D")).end().
      find(".month").text(date.format("MMMM")).end().
      find(".year").text(date.format("YYYY")).end()

  prev: (e) ->
    e?.preventDefault()
    @changeMonth -1

  next: (e) ->
    e?.preventDefault()
    @changeMonth 1

  changeMonth: (d) ->
    next = @date.clone().add(d, "month")

    if d > 0
      max = @date.clone().startOf("month").add(1, "month").endOf("month")
      next = max if next.isAfter(max)

    @date = next
    @updateHeader()

    css = { transform: "translateX(#{d * -100}%)" }
    @$(".content .month").transition css, -> $(this).remove()
    @renderMonth().
      appendTo(@months).
      css(transform: "translateX(#{d * 100}%)").
      transition({ transform: "translateX(0%)" })

  choose: (e) ->
    e.preventDefault()
    date = $(e.target).
      closest(".date").
      addClass("active").
      siblings(".active").removeClass("active").end()
    @date = moment date.attr("date")

  ok: ->
    @trigger("ok", @date)
    @toggle.text @date.format('ll')
    @input.val(@date.format()).trigger("change")
    @hide()

  flick: (e) ->
    if e.orientation == "horizontal"
      if e.direction == 1
        @prev()
      else
        @next()

class App.TimeEditor extends App.Dialog
  events:
    "tap .dot": "choose"
    "tap header .hours": "showHours"
    "tap header .minutes": "showMinutes"
    "tap .ampm button": "selectAMPM"
    "tap [rel=ok]": "ok"
    "mousedown .clock": "mouseDown"
    "touchstart .clock": "mouseDown"

  init: ->
    @input = @parent?.find("[rel=time]") || $([])
    @time ||= parseInt(@input.val() || 0)
    @input.val(@time)
    @toggle = @parent?.find("[data-toggle=time]") || $([])
    @toggle.text @formatTime()
    super
    @update()
    @el.addClass("select-time")

  render: ->
    data =
      hours: @hours()
      minutes: @minutes()
      time: @moment()
    @html @view("date/time")(data)

  moment: ->
    moment new Date(2015, 0, 1, @hours(), @minutes())

  formatTime: (time = @time) ->
    @moment().format('LT')

  hours: (value) ->
    if value?
      @time = (@pm() * 12 + value % 12) * 3600 + @minutes() * 60
      @update()
    Math.floor(@time / 3600)

  minutes: (value) ->
    if value?
      @time = @hours() * 3600 + value * 60
      @update()
    Math.round((Math.floor(@time / 60) % 60) / 5) * 5

  pm: (value) ->
    if value?
      @time = (+value * 12 + @hours() % 12) * 3600 + @minutes() * 60
      @update()
    @time >= (12 * 3600)

  update: ->
    moment = @moment()
    @$("header .hours").text moment.format("h")
    @$("header .minutes").text moment.format("mm")
    @$("header .ampm").text moment.format("A")
    @$(".hours .dot[value=#{(@hours() + 11) % 12 + 1}]").
      addClass("active").
      siblings(".active").
      removeClass("active")
    @$(".minutes .dot[value=#{@minutes()}]").
      addClass("active").
      siblings(".active").
      removeClass("active")
    @$(".ampm [rel=am]").toggleClass("active", !@pm())
    @$(".ampm [rel=pm]").toggleClass("active", @pm())

  choose: (e) ->
    el = $(e.target).closest(".dot")
    value = parseInt(el.attr("value"), 10)

    if el.closest(".clock").hasClass("hours")
      @hours(value)
    else
      @minutes(value)

  mouseDown: (e) =>
    e.preventDefault()
    @clock = $(e.target).closest(".clock")
    offset = @clock.offset()
    @center =
      x: offset.left + @clock.width() / 2
      y: offset.top + @clock.height() / 2

    $(document).
      on("mousemove", @mouseMove).
      on("touchmove", @mouseMove).
      on("mouseup", @mouseUp).
      on("touchend", @mouseUp)

    @mouseMove(e)

  mouseMove: (e) =>
    e.preventDefault()
    position = @getPosition(e)
    dx = position.x - @center.x
    dy = @center.y - position.y # y-axis is inverted

    # Not a mistake!
    # Giving dx first gives a clockwise angle from 12:00
    angle = Math.atan2(dx, dy) * 180 / Math.PI
    position = (Math.round(angle / 30) + 12) % 12

    dot = @clock.children().eq(position)
    unless dot.hasClass("active")
      dot.trigger("tap")

  mouseUp: (e) =>
    $(document).
      off("mousemove", @mouseMove).
      off("touchmove", @mouseMove).
      off("mouseup", @mouseUp).
      off("touchend", @mouseUp)

  getPosition: (e) ->
    if e.originalEvent.targetTouches?.length
      {
        x: e.originalEvent.targetTouches[0].pageX
        y: e.originalEvent.targetTouches[0].pageY
      }
    else
      { x: e.pageX, y: e.pageY }

  selectAMPM: (e) ->
    el = $(e.target).closest("button")
    @pm(el.attr("rel") == "pm")

  showHours: (e) ->
    @$(".hours").addClass("active").siblings(".active").removeClass("active")

  showMinutes: (e) ->
    @$(".minutes").addClass("active").siblings(".active").removeClass("active")

  ok: ->
    @trigger("ok", @time)
    @toggle.text @moment().format('LT')
    @input.val(@time).trigger("change")
    @hide()

$ ->
  $(document).on "click", ".date-select [data-toggle=date]", (e) ->
    e.preventDefault()
    new App.DateEditor(parent: $(this).closest(".date-select"))

  $(document).on "click", ".time-select [data-toggle=time]", (e) ->
    e.preventDefault()
    new App.TimeEditor(parent: $(this).closest(".time-select"))
