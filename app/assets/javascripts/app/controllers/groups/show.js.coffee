#= require ../groups

class App.Groups.Show extends App.Section.Page
  back: "/groups"

  init: ->
    super
    @el.addClass("show-group")
    @title @group.name
    @content.html @view("groups/show")(group: @group)
