class App.Dialog extends Spine.Controller
  init: ->
    @el.addClass("dialog")
      .appendTo("body")
      .data("dialog", this)
    @backdrop()
    @render()

    @el.on("click",  ".dialog-footer button", @buttonClicked)
    @el.on("click",  "[rel=cancel]", @hide)
    @el.on("submit", "form", @submit)

    setTimeout @show, 0 unless @auto == false

  render: ->
    @content = $("<div>", class: "dialog-content").appendTo(@el)
    @footer = $("<footer>", class: "dialog-footer").appendTo(@el)

  show: =>
    @el.trigger("show.dialog")
    @backdrop().addClass("in")
    @position()
    @el
      .addClass("in")
      .one($.support.transitionEnd, @shown)
    @$("input, textarea").first().focus()
    $(window).on "resize", @position

  shown: =>
    @el.trigger("shown.dialog")

  hide: (e) =>
    e?.preventDefault()
    @trigger("hide.dialog")
    @el
      .removeClass("in")
      .one($.support.transitionEnd, @hidden)
    @el.prev(".dialog-backdrop").removeClass("in")
    $(window).off "resize", @position

  hidden: (e) =>
    @trigger("hidden.dialog")
    @el.prev(".dialog-backdrop").remove()
    @release()

  close: (e) =>
    e?.preventDefault()
    @trigger "cancel", this
    @hide()

  backdrop: ->
    backdrop = $(".dialog-backdrop")
    unless backdrop.length
      backdrop = $("<div>", class: "dialog-backdrop")
        .insertBefore(@el)
    backdrop

  position: =>
    h = @el.height()
    @el
      .css(marginTop: h / -2)

  addButton: (rel, text) ->
    $("<button>", rel: rel, text: text).appendTo(@footer)

  buttonClicked: (e) =>
    e.preventDefault()
    @trigger $(e.target).closest("button").attr("rel"), this

  submit: (e) =>
    e.preventDefault()
    @$(".dialog-footer [rel=ok]").click()

$ ->
  $(document)
    .on "click", ".dialog-backdrop", ->
      $(".dialog").last().data("dialog")?.hide()
    .on "keydown", (e) ->
      if e.which is 27
        $(".dialog").last().data("dialog")?.hide()
