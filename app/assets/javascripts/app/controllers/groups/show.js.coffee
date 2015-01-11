#= require ../groups

class App.Groups.Show extends App.Section.Page
  back: "/groups"

  elements:
    ".upcoming-events": "upcoming"

  events:
    "tap .upcoming-events .primary-action": "showEvent"
    "tap .floating-action-button[rel=add]": "newEvent"

  init: ->
    super
    @el.addClass("show-group")
    @title @group.name
    @render()
    @group.on("change", @render)
    App.Event.on("refresh change", @refreshEvents).fetchGroup(@group)

    @on "release", =>
      @group.off("change", @render)
      App.Event.off("refresh change", @refreshEvents)

  render: =>
    @html @view("groups/show")(group: @group)
    @refreshEvents()

  renderHeader: ->
    super

    icon = "<i class=\"icon-add\"></i>"
    $("<a>", href: "#{@group.url()}/events/new", html: icon, rel: "add").
      addClass("button floating-action-button").
      appendTo(@footer)

  refreshEvents: =>
    events = App.Event.
      findAllByAttribute("group_id", @group.id).
      sort(App.Event.comparator).
      slice(0, 3)

    @upcoming.empty()
    for event in events
      @upcoming.append $(@view("events/item")({ event })).data({ event })

  showEvent: (e) ->
    e.preventDefault()
    event = $(e.target).closest(".event").data("event")
    controller = new App.Events.Show(event: event, back: @group.url())
    Spine.Route.navigate event.url(), false
    @parent.push controller

  newEvent: (e) ->
    e.preventDefault()
    event = new App.Event(group_id: @group.id)
    @edit event
    controller = new App.Events.Edit(event: event, back: @group.url())
    Spine.Route.navigate group.url() + "/events/new", false
    @parent.push controller
