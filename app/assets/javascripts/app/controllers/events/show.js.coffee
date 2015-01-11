#= require ../events

class App.Events.Show extends App.Section.Page
  back: "/events"

  events:
    "tap header [rel=edit]": "editEvent"

  init: ->
    super

    @el.addClass("show-event")
    @event.on "change", @render
    @render()

    @on "release", =>
      @event.off "change", @render

  render: =>
    @header.
      css(backgroundColor: @event.group().color()).
      find(".title").empty().
      append($("<h1>", text: @event.name())).
      append($("<h2>", text: @event.dateRange().toString()))
    @html @view("events/show")(event: @event)

  renderHeader: =>
    super
    $("<a>", rel: "edit", href: @event.url("edit")).
      addClass("button").
      append($("<i>", class: "icon-settings")).
      appendTo(@header)

  editEvent: (e) ->
    e.preventDefault()
    controller = new App.Events.Edit(event: @event, back: @event.url())
    Spine.Route.navigate @event.url("edit"), false
    @parent.push controller
