#= require ./section

class App.Groups extends App.Section
  className: "groups"

  init: ->
    super
    @append new App.Groups.Index

  index: ->
    @active()
    @manager.controllers[0].active()

  show: (id) ->
    @index()
    if group = App.Group.findByAttribute "slug", id
      page = new App.Groups.Index({ group })
      @push page
      page.active()
    else
      Spine.Route.navigate "/groups", false

class App.Groups.Index extends App.Section.Page
  back: "/groups"

  init: ->
    super
    @title I18n.t("groups.index.title")
    App.Group.bind "refresh change", @render

    @sidebarList = $(".main-navigation .groups-list")
    App.Group.bind "refresh change", @renderSidebarList

    @sidebarList.on "click", "[rel=preferences]", (e) ->
      e.preventDefault()
      group = App.Group.find($(e.target).closest("[group-id]").attr("group-id"))
      new App.GroupPreferences({ group })

  render: =>
    @content.html @view("groups/index")(groups: App.Group.sort().all())

  renderSidebarList: =>
    @sidebarList.empty()
    for group in App.Group.sort().all()
      @sidebarList.append @renderItem(group)

  renderItem: (group) ->
    @view("groups/item")({ group })

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

class App.Groups.Show extends App.Section.Page
  init: ->
    super
    @title @group.name
