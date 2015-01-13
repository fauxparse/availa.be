class App.Alert extends Spine.Controller
  DELAY: 10000

  events:
    "click .clear": "hide"
    "click button:not(.clear)": "click"

  init: ->
    @container = App.Alert.container

    unless @el.hasClass("alert")
      @render()
      @show()

    @timer = setTimeout @hide, @DELAY

  render: ->
    @el.addClass("alert")
    @append $("<div>", class: "text", text: @text)
    if @button
      @append $("<button>", text: @button)
    @append $("<button>", class: "clear").append($("<i>", class: "icon-clear"))

  show: ->
    @appendTo @container
    @el.css(opacity: 0).transition(opacity: 1)
    h = @el.outerHeight(true)
    @container.
      css(transform(h)).
      transition(transform(0))
    positionFloatingContent()

  floatingButton: ->
    if @container.css("position") == "absolute"
      $([])
    else
      $(".floating")

  hide: (e) =>
    e?.preventDefault()
    clearTimeout @timer

    @el.css(pointerEvents: "none")
    @el.transition { opacity: 0 }, =>
      h = @el.outerHeight(true)
      @el.addClass("deleting")
      @el.nextAll().transition(transform(-h))
      positionFloatingContent()

      @container.transition transform(h), =>
        @el.nextAll().css(transform(0))
        @container.css(transform(0))
        @release()

  click: (e) ->
    @trigger "click"
    @hide()

transform = (top, opacity) ->
  hash = { queue: false }
  hash[$.support.transform] = "translateY(#{top}px)"
  hash

positionFloatingContent = ->
  container = App.Alert.container
  footers = $(".pages>section>footer")

  if parseInt(container.css("right"), 10) > 0
    footers.transition transform(0)
  else
    h = container.outerHeight()
    container.find(".deleting").each ->
      h -= $(this).outerHeight(true)
    footers.transition transform(-h)

$ ->
  App.Alert.container = $("footer.alerts")

  App.Alert.container.find(".alert").each ->
    new App.Alert(el: this)

  $(window).on "resize", positionFloatingContent
