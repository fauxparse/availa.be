class App.Alert extends Spine.Controller
  DELAY: 10000

  events:
    "click .clear": "hide"
    "click button:not(.clear)": "click"

  init: ->
    @container = App.Alert.container
    @footer = @container.closest("footer")

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
      add(@floatingButton()).
      css(@transform(h)).
      transition(@transform(0))

  transform: (top, opacity) ->
    hash = {}
    hash[$.support.transform] = "translateY(#{top}px)"
    hash

  floatingButton: ->
    @container.filter(-> $(this).css("position") != "absolute").nextAll(".floating")

  hide: (e) =>
    e?.preventDefault()
    clearTimeout @timer

    @el.
      css(pointerEvents: "none").
      transition { opacity: 0 }, =>
        h = @el.outerHeight(true)
        @el.nextAll().transition(@transform(-h))

        elements = @container.add @floatingButton()
        elements.transition @transform(h), =>
          @el.nextAll().css(@transform(0))
          elements.css(@transform(0))
          @release()

  click: (e) ->
    @trigger "click"
    @hide()

$ ->
  App.Alert.container = $("footer .alerts")

  App.Alert.container.find(".alert").each ->
    new App.Alert(el: this)

  # $(".floating-action-button").on "click", (e) ->
  #   new App.Alert(text: "Taxidermy cred Marfa actually squid semiotics bespoke health goth Helvetica.", button: "Derp")
