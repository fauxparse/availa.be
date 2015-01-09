class App.Event extends Spine.Model
  @configure "Event", "name", "recurrences"
  @extend Spine.Model.Ajax

  name: (value) ->
    @_name = value if value?
    @_name || "New event"

  recurrences: (value) ->
    @_recurrences = Recurrence.fromJSON(value) if value?
    @_recurrences ||= [new Recurrence()]

  start_date: (value) ->
    @recurrences()[0].start_date(value)

  end_date: (value) ->
    @recurrences()[0].end_date(value)

  start_time: (value) ->
    @recurrences()[0].start_time(value)

  end_time: (value) ->
    @recurrences()[0].end_time(value)

  weekdays: (value) ->
    @recurrences()[0].weekdays(value)

class Recurrence extends Spine.Model
  @configure "Recurrence",
    "start_date",
    "end_date",
    "weekdays",
    "start_time",
    "end_time",
    "time_zone"

  start_date: (value) ->
    @_start_date = @handleDate(value) if value?
    @_start_date || moment().startOf("day")

  end_date: (value) ->
    @_end_date = @handleDate(value) if value?
    @_end_date || moment().endOf("day")

  start_time: (value) ->
    @_start_time = parseInt(value, 10) if value?
    @_start_time || 19 * 3600 + 30 * 60

  end_time: (value) ->
    @_end_time = parseInt(value, 10) if value?
    @_end_time || 21 * 3600

  handleDate: (value) ->
    if moment.isMoment(value)
      value.clone()
    else
      moment(value)

  weekdays: (value) ->
    @_weekdays = value.slice(0) if value?
    @_weekdays || [@start_date().day()]

  time_zone: ->
    moment.defaultZone.name

  toJSON: ->
    $.extend {}, super,
      start_date: @start_date().format(),
      end_date: @end_date().format(),
