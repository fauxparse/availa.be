#= require ../groups

class App.Groups.Show extends App.Section.Page
  back: "/groups"

  elements:
    "header [rel=edit]": "settingsButton"
    ".upcoming-events": "upcoming"

  init: ->
    super
    @el.addClass("show-group")
    App.Event.on("refresh change", @refreshEvents)
    @on "release", =>
      @group.off("change", @render)
      App.Event.off("refresh change", @refreshEvents)

  load: (params) ->
    @el.addClass("loading")
    @group = App.Group.findByAttribute "slug", params.group_id
    @title @group.name()
    @render()
    @group.on("change", @render)
    App.Group.on "ajaxSuccess", @loaded
    App.Group.fetch { id: @group.id }, { url: @group.url() }
    App.Event.fetchGroup(@group)

  loaded: =>
    setTimeout =>
      if App.Group.exists @group.id
        @group = App.Group.find @group.id
        @settingsButton.attr("href", @group.url() + "/preferences")
        @el.removeClass "loading"
        App.Group.off "ajaxSuccess", @loaded
        @_loaded = true
    , 0

  render: =>
    @header.css(backgroundColor: @group.color())
    @html @view("groups/show")(group: @group)
    @refreshEvents()

  renderHeader: ->
    super

    $("<a>", rel: "edit", href: "#").
      addClass("button").
      append($("<i>", class: "icon-settings")).
      appendTo(@header)
    @refreshElements()

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
