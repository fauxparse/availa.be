#= require ./dashboard
#= require ./events
#= require ./groups

class App.Sections extends Spine.Stack
  controllers:
    dashboard: App.Dashboard
    events: App.Events
    groups: App.Groups

  routes:
    "/events/new":                      -> @events.build()
    "/events/:id":             (params) -> @events.edit(params.id)
    "/events":                          -> @events.index()
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
