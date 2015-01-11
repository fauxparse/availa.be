#= require ./dashboard
#= require ./events
#= require ./groups

class App.Sections extends Spine.Stack
  controllers:
    dashboard: App.Dashboard
    events: App.Events
    groups: App.Groups

  routes:
    "/calendar":                                  -> @events.calendar()
    "/groups/:group_id/events/new":      (params) -> @groups.newEvent(params)
    "/groups/:group_id/events/:id/edit": (params) -> @groups.editEvent(params)
    "/groups/:group_id/events/:id":      (params) -> @groups.showEvent(params)
    "/groups/:group_id/events":          (params) -> @groups.events(params)
    "/groups/:id/preferences":           (params) -> @groups.preferences(params)
    "/groups/:id":                       (params) -> @groups.show(params)
    "/groups":                                    -> @groups.index()
    "/":                                          -> @dashboard.active()

  constructor: ->
    super
    @el.addClass "sections"
    @manager.on "change", @hideSidebar

  hideSidebar: ->
    $("#show-navigation")[0].checked = false
