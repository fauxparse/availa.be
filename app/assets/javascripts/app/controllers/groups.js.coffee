#= require ./section

class App.Groups extends App.Section
  className: "groups"

  init: ->
    super
    @push new App.Groups.Index

  index: ->
    @active()
    @manager.controllers[0].active()

  show: (params) ->
    if group = App.Group.findByAttribute("slug", params.id)
      current = @find App.Groups.Show, (controller) ->
        controller.group.id == group.id
      if current
        current.active()
      else
        @index()
        @push new App.Groups.Show({ group })
    else
      Spine.Route.navigate "/groups"

  events: (params) ->
    if group = App.Group.findByAttribute("slug", params.group_id)
      current = @find App.Events.Index, (controller) ->
        controller.group.id == group.id
      if current
        current.active()
      else
        @show id: params.group_id
        @push new App.Events.Index(group: group, back: group.url())
    else
      Spine.Route.navigate "/groups"

  newEvent: (params) ->
    if group = App.Group.findByAttribute("slug", params.group_id)
      current = @find App.Events.Edit, (controller) ->
        controller.event.isNew()
      if current
        current.active()
      else
        @events params
        event = new App.Event(group_id: group.id)
        @push new App.Events.Edit(event: event, back: group.url() + "/events")
    else
      Spine.Route.navigate "/groups"

  showEvent: (params) ->
    if group = App.Group.findByAttribute("slug", params.group_id)
      if (event = App.Event.find(params.id)) && event.group_id == group.id
        current = @find App.Events.Show, (controller) ->
          controller.event.eql(event)
        if current
          current.active()
        else
          @events params
          @push new App.Events.Show(event: event, back: group.url() + "/events")
      else
        # TODO: load event via AJAX
        Spine.Route.navigate group.url()
    else
      Spine.Route.navigate "/groups"

  editEvent: (params) ->
    if group = App.Group.findByAttribute("slug", params.group_id)
      if (event = App.Event.find(params.id)) && event.group_id == group.id
        current = @find App.Events.Edit, (controller) ->
          controller.event.eql(event)
        if current
          current.active()
        else
          @events params
          @push new App.Events.Edit(event: event, back: group.url() + "/events")
      else
        # TODO: load event via AJAX
        Spine.Route.navigate group.url()
    else
      Spine.Route.navigate "/groups"

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
