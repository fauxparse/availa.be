class App.EventsController extends Spine.Section
  className: "events"

  init: ->
    super
    @push new App.EventsController.Calendar
