class App.Event extends Spine.Model
  @configure "Event", "name", "recurrences"
  @extend Spine.Model.Ajax

  recurrences: (value) ->
    if value
      @_recurrences = value.slice(0)
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
  @configure "Recurrence", "start_date", "end_date", "weekdays", "start_time", "end_time"

  start_date: (value) ->
    if value?
      @_start_date = @handleDate(value)
    @_start_date || moment().startOf("day")

  end_date: (value) ->
    if value?
      @_end_date = @handleDate(value)
    @_end_date || moment().endOf("day")

  start_time: (value) ->
    if value?
      @_start_time = parseInt(value, 10)
    @_start_time || 19 * 3600 + 30 * 60

  end_time: (value) ->
    if value?
      @_end_time = parseInt(value, 10)
    @_end_time || 21 * 3600

  handleDate: (value) ->
    if moment.isMoment(value)
      value.clone()
    else
      moment(value)

  weekdays: (value) ->
    if value?
      @_weekdays = value.slice(0)
    @_weekdays || [@start_date().day()]
