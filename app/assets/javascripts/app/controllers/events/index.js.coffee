#= require ../events

class App.Events.Index extends App.Section.Page
  init: ->
    super
    @el.addClass("index-events")
