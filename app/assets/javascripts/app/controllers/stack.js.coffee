#= require ./dashboard
#= require ./events

class App.Stack extends Spine.Stack
  controllers:
    dashboard: App.DashboardController
    events: App.EventsController
    groups: App.GroupsController

  routes:
    "/events": -> @events.active()
    "/groups/:id/preferences": -> @groups.active()
    "/groups/:id": -> @groups.active()
    "/groups": -> @groups.active()
    "/":       -> @dashboard.active()

  constructor: ->
    super
    @manager.bind "change", @hideSidebar

  hideSidebar: ->
    $("#show-navigation")[0].checked = false
