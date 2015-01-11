#= require ../events

class App.Events.Edit extends App.Section.Page
  back: "/events"

  events:
    "input [name=name]": "nameChanged"
    "change [rel=date]": "dateChanged"
    "change [rel=time]": "dateChanged"
    "change [name=weekdays]": "weekdaysChanged"
    "tap header [rel=ok]": "save"

  init: ->
    super
    @el.addClass "edit-event"
    @title I18n.t("events.#{@action()}.title")
    @render()

  render: =>
    weekdays = ([w, i] for w, i in moment.weekdaysMin()).
      rotate(-moment().startOf("week").day())
    @content.html @view("events/edit")(event: @event, weekdays: weekdays)
    @checkWeekdays()

  renderHeader: ->
    super
    $("<button>", rel: "ok").append($("<i>", class: "icon-done")).appendTo(@header)

  action: ->
    if @event?.isNew()
      "new"
    else
      "edit"

  nameChanged: (e) ->
    @event.name $(e.target).val()

  dateChanged: (e) ->
    input = $(e.target)
    @event[input.attr("name")] input.val()
    @checkWeekdays()

  timeChanged: (e) ->
    input = $(e.target)
    @event[input.attr("name")] input.val()

  weekdaysChanged: (e) ->
    values = @$("[name=weekdays]:checked").
      map(-> parseInt($(this).val(), 10)).
      get()
    @event.weekdays values

  checkWeekdays: (e) ->
    d = @event.start_date().clone()
    i = 0
    valid = {}
    days = []

    while i < 7 and !d.isAfter(@event.end_date())
      valid[d.day()] = true
      d.add(1, "day")
      i++

    @$(".weekdays input").each (i, el) =>
      el = $(el)
      day = parseInt(el.val(), 10)
      if valid[day]
        el.removeAttr("disabled")
        days.push day if el.is(":checked")
      else
        el.attr("disabled", true).removeAttr("checked")

    @event.weekdays days

  save: (e) ->
    url = if @event.isNew()
      @event.group().url() + App.Events.url()
    else
      @event.url()
    @event.save(url: url)
