#= require ./section

class App.Events extends App.Section
  className: "events"

  init: ->
    super
    @push new App.Events.Calendar

  index: (params)->
    @active()
    @change @manager.controllers[0]

  build: (params) ->
    @index(params)
    group = App.Group.findByAttribute "slug", params.group_id
    if group.admin
      @push new App.Events.Edit(event: new App.Event(group_id: group.id))

  edit: (params) ->
    @index(params)
    group = App.Group.findByAttribute "slug", params.group_id
    if group.admin
      @push new App.Events.Edit(id: id)
