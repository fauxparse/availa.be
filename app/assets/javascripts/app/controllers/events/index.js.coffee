#= require ../events

class App.Events.Index extends App.Section.Page
  init: ->
    super
    @el.addClass("index-events")
    @title I18n.t("events.index.title", group: @group)

    $("<a>", href: "/groups/#{@group.slug}/events/new").
      html("<i class=\"icon-add\"></i>")
      addClass("button floating-action-button").
      appendTo(@footer)
