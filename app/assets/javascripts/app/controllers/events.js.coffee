#= require ./section

class App.Events extends App.Section
  className: "events"

  init: ->
    super
    @push new App.Events.Calendar

  index: ->
    @active()
    @change @manager.controllers[0]

  build: ->
    @index()
    @push new App.Events.Edit(event: new App.Event)

  edit: (id) ->
    @index()
    @push new App.Events.Edit(id: id)
