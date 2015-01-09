#= require ../events

class App.Events.Edit extends App.Section.Page
  back: "/events"

  events:
    "change [rel=date]": "dateChanged"
    "tap header [rel=ok]": "save"

  init: ->
    super
    @el.addClass "edit-event"
    @title I18n.t("events.#{@action()}.title")

    if @event?.isNew()
      @render()
    else
      App.Event.on("refresh", @loaded)
      @id ||= @event?.id
      App.Event.fetch(id: @id, cache: false)

  loaded: (events) =>
    for event in events when event.id == @id
      App.Event.off "refresh", @loaded
      @event = event
      @render()
      break

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

  dateChanged: (e) ->
    input = $(e.target)
    @event[input.attr("name")] input.val()
    @checkWeekdays()

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
    @event.save()
