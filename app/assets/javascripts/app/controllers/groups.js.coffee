#= require ./section

class App.Groups extends App.Section
  className: "groups"

  init: ->
    super
    @push new App.Groups.Index

  index: =>
    @active()
    @manager.controllers[0].active()

  withGroup: (id, callback) =>
    if group = App.Group.findByAttribute("slug", id)
      callback.call this, group
    else
      Spine.Route.navigate "/groups"

  show: (params) =>
    @withGroup params.id, =>
      @load App.Groups.Show, { group_id: params.id }, @index

  events: (params) =>
    @withGroup params.group_id, =>
      @load App.Events.Index, params, => @show(id: params.group_id)

  newEvent: (params) =>
    @withGroup params.group_id, (group) =>
      params = $.extend {}, params, back: group.url() + "/events"
      @load App.Events.Edit, params, => @events(params)

  showEvent: (params) =>
    @withGroup params.group_id, (group) =>
      params = $.extend {}, params, back: group.url() + "/events"
      @load App.Events.Show, params, => @events(params)

  editEvent: (params) =>
    @withGroup params.group_id, (group) =>
      params = $.extend {}, params, back: group.url() + "/events/#{params.id}"
      @load App.Events.Edit, params, => @showEvent(params)

class App.GroupPreferences extends App.Dialog
  events:
    "tap .color": "choose"
    "click .color": "choose"
    "click [rel='ok']": "save"

  init: ->
    super
    @el.addClass "group-preferences"
    @content.html @view("groups/preferences")(group: @group)
    @addButton "cancel", I18n.t("dialogs.cancel")
    @addButton "ok", I18n.t("groups.preferences.save")

  choose: (e) ->
    $(e.target).closest(".color")
      .addClass("active")
      .siblings(".active").removeClass("active")

  save: (e) ->
    @group.preferences color: @$(".color.active").attr("color")
    @hide()
