#= require ../groups

class App.Groups.Index extends App.Section.Page
  back: "/groups"

  init: ->
    super
    @el.addClass("index-groups")
    @title I18n.t("groups.index.title")
    App.Group.bind "refresh change", @render

    @sidebarList = $(".main-navigation .groups-list")
    App.Group.bind "refresh change", @renderSidebarList

  render: =>
    @content.html @view("groups/index")(groups: App.Group.sort().all())

  renderSidebarList: =>
    @sidebarList.empty()
    for group in App.Group.sort().all()
      @sidebarList.append @renderItem(group)

  renderItem: (group) ->
    @view("groups/item")({ group })
