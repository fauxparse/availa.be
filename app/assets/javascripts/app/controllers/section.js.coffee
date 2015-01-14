class App.Section extends Spine.Controller
  tag: "section"

  init: ->
    @pages = $("<div>").addClass("pages").appendTo(@el)
    @pages.bind $.support.transitionEnd, @truncate
    @manager = new Spine.Manager
    @manager.on "change", @change
    @_index = 0

  push: (controller) ->
    @queue =>
      controller.parent = this
      controller.el.css(left: "#{@manager.controllers.length * 100}%")
      @pages.append controller.el
      @manager.add controller
      controller.active()

  pop: ->
    if @manager.controllers.length > 1
      @manager.controllers[@manager.controllers.length - 1].active()
      @queue @truncate

  change: (controller) =>
    @active()
    index = controller.el.prevAll("section").length
    if @_index == index
      @truncate()
    else
      @_index = index
      @pages.css transform: "translateX(#{@_index * -100}%)"

  queue: (callback) ->
    @el.queue =>
      callback()
      @el.dequeue()

  truncate: (e) =>
    if !e?.target? || e.target == @pages[0]
      index = Math.max(@pages.children(".active").prevAll().length, 0) + 1
      count = @manager.controllers.length - index
      for controller in @manager.controllers.splice(index, count)
        controller.release()

  find: (constructor, match) ->
    for c in @manager.controllers
      return c if (c.constructor == constructor) && (!match? || match(c))
    undefined

  findOrPush: (constructor, params, prerequisite = nil) ->
    for controller in @manager.controllers
      if controller.constructor == constructor
        controller.active()
        controller.load params
        return controller
    prerequisite?()
    controller = new constructor
    @push controller
    controller.load params

  empty: ->
    !@manager.controllers.length

  activeController: ->
    for controller in @manager.controllers
      if controller.el.hasClass("active")
        return controller

class App.Section.Page extends Spine.Controller
  tag: "section"

  init: ->
    @el.addClass("page")
    @header = $("<header>").addClass("app-bar").appendTo(@el)
    @content = $("<section>").addClass("content").appendTo(@el)
    @footer = $("<footer>").appendTo(@el)
    @loading = $("<div>", class: "loading-spinner").appendTo(@el)
    @renderHeader()

  renderHeader: ->
    @header.html @view("shared/section_header")(back: @back || "/")

  title: (title) ->
    @header.find(".title").text(title)

  html: (element) ->
    @content.html(element.el or element)
    @refreshElements()
    @content

  load: (params) ->
