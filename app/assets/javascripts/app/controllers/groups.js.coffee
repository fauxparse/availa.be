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
    @queue =>
      if group = App.Group.findByAttribute("slug", params.id)
        if current = @find(App.Groups.Show, (controller) -> controller.group.id == group.id)
          current.active()
        else
          @index()
          @push new App.Groups.Show({ group })
      else
        Spine.Route.navigate "/groups", false

  events: (params) ->
    @queue =>
      if group = App.Group.findByAttribute("slug", params.group_id)
        if current = @find(App.Events.Index, (controller) -> controller.group.id == group.id)
          current.active()
        else
          @show id: params.group_id
          @push new App.Events.Index(group: group, back: group.url())
      else
        Spine.Route.navigate "/groups", false

  newEvent: (params) ->
    @queue =>
      if group = App.Group.findByAttribute("slug", params.group_id)
        if current = @find(App.Events.Edit, (controller) -> controller.group.isNew())
          current.active()
        else
          @events params
          console.log "B"
          @push new App.Events.Edit(event: new App.Event(group_id: group.id), back: group.url())
      else
        Spine.Route.navigate "/groups", false

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
