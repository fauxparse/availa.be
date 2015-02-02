#= require ../events

class App.Events.Show extends App.Section.Page
  back: "/events"

  elements:
    "header": "header"

  events:
    "tap .instances .primary-action": "showInstance"
    "tap .instance-availability .avatar": "cycleMyAvailability"

  init: ->
    super
    @el.addClass("show-event")
      .on("scroll", @scroll)
    @on "release", =>
      @event?.off("change", @render)
        .off("instance", @updateInstance)

  load: (params) ->
    @event?.off "change", @render
    @event_id = params.id
    @group = App.Group.find(params.group_id)

    @_loaded = false
    @event = App.Event.find(@event_id) ||
      new App.Event(id: @event_id, group_id: @group.id)
    @render()

    if @event_id
      @el.addClass "loading"
      url = @event.url()
      App.Event.on "ajaxSuccess", @loaded
      App.Event.fetch { id: @event_id }, { url: url, cache: false }

    @render()

    @back = params.back || "/groups/#{params.group_id}"
    @$("header [rel=back]").attr href: @back

  loaded: =>
    setTimeout =>
      if App.Event.exists(@event_id)
        @event = App.Event.find @event_id
        @event.on "change", @render
        @event.on "instance", @updateInstance
        @el.removeClass "loading"
        App.Event.off "ajaxSuccess", @loaded
        @_loaded = true
        App.Group.wait(@event.group_id, false).done @render
    , 0

  render: =>
    @header.
      css(backgroundColor: @event.group().color()).
      find("[rel=edit]").attr(href: @event.url("edit")).end()
    unless @event.isNew()
      @header.
        find(".title").empty().
        append($("<h1>", text: @event.name())).
        append($("<h2>", text: @event.dateRange().toString())).
        end()
    @content.empty()
    if @_loaded
      @html @view("events/show")(event: @event)
      App.Group.wait(@event.group_id, false).done @updateInstances
    @resize()

  renderHeader: =>
    super
    $("<a>", rel: "edit", href: "#").
      addClass("button").
      append($("<i>", class: "icon-settings")).
      appendTo(@header)
    @refreshElements()

  resize: ->
    @_scrollMin = parseInt @header.css("minHeight"), 10
    @_scrollOffset = (@header.outerHeight() - @_scrollMin)
    @scroll()

  scroll: =>
    scrollTop = @el.scrollTop()
    top = Math.max(0, scrollTop - @_scrollOffset)
    @header
      .toggleClass("floating", !!top)
      .css(y: top)
    @header.find(".top-left-button, [rel=edit]")
      .css y: Math.min(scrollTop, @_scrollMin + 16)

  activate: ->
    super
    @resize()

  updateInstances: =>
    for instance in @event.instances().all()
      @updateInstance instance

  updateInstance: (instance) =>
    li = @$(".list-item[time=\"#{instance.time().toISOString()}\"]")
    current = App.User.current()
    available = instance.isAvailable(current)
    li
      .toggleClass("assigned", instance.assigned(current))
      .toggleClass("available", !!available)
      .toggleClass("unavailable", available == false)
      .find(".description").text(instance.description()).end()

  showInstance: (e) ->
    e.preventDefault()
    source = $(e.target).closest("li")
    instance = @event.instances().find source.attr("time")
    controller = new App.Events.Instance { instance }
    controller.showFrom source

  cycleMyAvailability: (e) ->
    time = moment($(e.target).closest("li").attr("time"))
    current = App.User.current()
    instance = @event.instances().find(time)
    unless instance.assigned(current)
      e.stopPropagation()
      instance.cycleAvailability(current)
