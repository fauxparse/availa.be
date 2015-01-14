#= require ../events

class App.Events.Show extends App.Section.Page
  back: "/events"

  init: ->
    super
    @el.addClass("show-event")
    App.Event.on "refresh", @eventsRefreshed
    @on "release", =>
      App.Event.off "refresh", @eventsRefreshed
      @event?.off "change", @render

  load: (params) ->
    @event?.off "change", @render
    @event_id = params.id

    params.back ||= "/groups/#{params.group_id}"
    @$("header [rel=back]").attr href: params.back

    url = "/groups/#{params.group_id}/events/#{params.id}"
    App.Event.fetch({ id: @event_id }, { url })

  eventsRefreshed: (events) =>
    events = [events] unless $.isArray(events)
    for event in events
      if event.id == @event_id
        @event = event
        @event.on "change", @render
        @render()
        break

  render: =>
    @header.
      css(backgroundColor: @event.group().color()).
      find(".title").empty().
      append($("<h1>", text: @event.name())).
      append($("<h2>", text: @event.dateRange().toString())).
      end().
      find("[rel=edit]").attr(href: @event.url("edit")).end()
    @html @view("events/show")(event: @event)

  renderHeader: =>
    super
    $("<a>", rel: "edit", href: "#").
      addClass("button").
      append($("<i>", class: "icon-settings")).
      appendTo(@header)
    @refreshElements()
