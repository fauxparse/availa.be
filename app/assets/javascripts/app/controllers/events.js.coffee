#= require ./section

class App.Events extends App.Section
  className: "events"

  init: ->
    super
    @push new App.Events.Calendar

  index: (params) =>
    @active()
    @change @manager.controllers[0]

  calendar: (params) =>
    @load App.Events.Calendar, params, @index
