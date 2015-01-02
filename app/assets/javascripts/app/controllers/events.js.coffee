class App.EventsController extends Spine.Section
  className: "events"

  init: ->
    super
    @title I18n.t("events.calendar.title")
