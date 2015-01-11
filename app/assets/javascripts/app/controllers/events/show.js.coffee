#= require ../events

class App.Events.Show extends App.Section.Page
  back: "/events"

  init: ->
    super

    @event.on "change", @render
    @render()

    @on "release", =>
      @event.off "change", @render

  render: =>
    @title @event.name()
    @html @view("events/show")(event: @event)
