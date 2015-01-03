class Spine.Section extends Spine.Controller
  tag: "section"

  init: ->
    @pages = $("<div>").addClass("pages").appendTo(@el)
    @manager = new Spine.Manager
    @manager.on "change", @change

  append: (controllers...) ->
    for controller in controllers
      @pages.append controller.el.css(left: "#{@manager.controllers.length * 100}%")

  change: =>

class Spine.Section.Page extends Spine.Controller
  tag: "section"

  init: ->
    @header = $("<header>").addClass("app-bar").appendTo(@el)
    @content = $("<section>").addClass("content").appendTo(@el)
    @renderHeader()

  renderHeader: ->
    @header.html @view("shared/section_header")

  title: (title) ->
    @header.find(".title").text(title)
