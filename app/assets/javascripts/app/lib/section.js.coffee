class Spine.Section extends Spine.Controller
  tag: "section"

  init: ->
    @pages = $("<div>").addClass("pages").appendTo(@el)
    @pages.bind $.support.transitionEnd, @truncate
    @manager = new Spine.Manager
    @manager.on "change", @change

  append: (controllers...) ->
    for controller in controllers
      @pages.append controller.el.css(left: "#{@manager.controllers.length * 100}%")
      @manager.add controller

  change: (controller) =>
    index = controller.el.prevAll("section").length
    @pages.css left: "#{index * -100}%"

  push: (controller) ->
    @append controller
    controller.active()

  pop: (e) =>
    e?.preventDefault()
    @manager.controllers.pop().release()

  truncate: (e) =>
    if e.target == @pages[0]
      count = Math.max(@pages.children(".active").prevAll().length, 0) + 1
      while @manager.controllers.length > count
        @pop()

  activate: ->
    super
    for controller in @manager.controllers when controller.el.hasClass("active")
      controller.activate()

class Spine.Section.Page extends Spine.Controller
  tag: "section"

  init: ->
    @header = $("<header>").addClass("app-bar").appendTo(@el)
    @content = $("<section>").addClass("content").appendTo(@el)
    @renderHeader()

  renderHeader: ->
    @header.html @view("shared/section_header")(back: @back || "/")

  title: (title) ->
    @header.find(".title").text(title)
