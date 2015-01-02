class App.Groups extends Spine.Section
  className: "groups"

  init: ->
    super
    @title I18n.t("groups.index.title")
    App.Group.bind "refresh", @render

    @sidebarList = $(".main-navigation .groups-list")
    App.Group.bind "refresh", @renderSidebarList

  render: =>
    @content.html @view("groups/index")(groups: App.Group.sort().all())

  renderSidebarList: =>
    @sidebarList.empty()
    for group in App.Group.sort().all()
      @sidebarList.append @renderItem(group)

  renderItem: (group) ->
    @view("groups/item")({ group })
