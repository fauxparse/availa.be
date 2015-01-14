#= require ../events

class App.Events.Index extends App.Section.Page
  init: ->
    super
    @el.addClass("index-events")

    # $("<a>", href: "/groups/#{@group.slug}/events/new").
    #   html("<i class=\"icon-add\"></i>")
    #   addClass("button floating-action-button").
    #   appendTo(@footer)

  load: (params) ->
    params.back ||= "/groups/#{params.group_id}"
    @$("header [rel=back]").attr href: params.back

    @group = App.Group.findByAttribute "slug", params.group_id
    @title I18n.t("events.index.title", group: @group)
