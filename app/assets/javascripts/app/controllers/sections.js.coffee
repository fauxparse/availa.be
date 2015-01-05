#= require ./dashboard
#= require ./events
#= require ./groups

class App.Sections extends Spine.Stack
  controllers:
    dashboard: App.DashboardController
    events: App.EventsController
    groups: App.GroupsController

  routes:
    "/events":                          -> @events.active()
    "/groups/:id/preferences": (params) -> @groups.preferences(params.id)
    "/groups/:id":             (params) -> @groups.show(params.id)
    "/groups":                          -> @groups.index()
    "/":                                -> @dashboard.active()

  constructor: ->
    super
    @el.addClass "sections"
    @manager.on "change", @hideSidebar

  hideSidebar: ->
    $("#show-navigation")[0].checked = false
