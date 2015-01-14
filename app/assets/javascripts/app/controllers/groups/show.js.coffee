#= require ../groups

class App.Groups.Show extends App.Section.Page
  back: "/groups"

  elements:
    ".upcoming-events": "upcoming"

  init: ->
    super
    @el.addClass("show-group")
    App.Event.on("refresh change", @refreshEvents)
    @on "release", =>
      @group.off("change", @render)
      App.Event.off("refresh change", @refreshEvents)

  load: (params) ->
    @group = App.Group.findByAttribute "slug", params.group_id
    @title @group.name
    @render()
    @group.on("change", @render)
    App.Event.fetchGroup(@group)

  render: =>
    @header.css(backgroundColor: @group.color())
    @html @view("groups/show")(group: @group)
    @refreshEvents()

  renderHeader: ->
    super

    # icon = "<i class=\"icon-add\"></i>"
    # $("<a>", href: "#{@group.url()}/events/new", html: icon, rel: "add").
    #   addClass("button floating-action-button").
    #   appendTo(@footer)

  refreshEvents: =>
    events = App.Event.
      findAllByAttribute("group_id", @group.id).
      sort(App.Event.comparator).
      slice(0, 3)

    @upcoming.empty()
    for event in events
      @upcoming.append $(@view("events/item")({ event })).data({ event })
