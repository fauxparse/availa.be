class App.EventsController extends Spine.Section
  className: "events"

  init: ->
    super
    @append new App.EventsController.Index

class App.EventsController.Index extends Spine.Section.Page
  init: ->
    super
    @title I18n.t("events.calendar.title")
