class Spine.Section extends Spine.Controller
  tag: "section"

  init: ->
    @header = $("<header>").addClass("app-bar").appendTo(@el)
    @content = $("<section>").addClass("content").appendTo(@el)
    @renderHeader()

  renderHeader: ->
    @header.html @view("shared/section_header")

  title: (title) ->
    @header.find(".title").text(title)
