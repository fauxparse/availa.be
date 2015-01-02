#= require ./dashboard
#= require ./events

class App.Stack extends Spine.Stack
  controllers:
    dashboard: App.Dashboard
    events: App.Events
    groups: App.Groups

  routes:
    "/events": -> @events.active()
    "/groups": -> @groups.active()
    "/":       -> @dashboard.active()

  constructor: ->
    super
    @manager.bind "change", @hideSidebar

  hideSidebar: ->
    $("#show-navigation")[0].checked = false
