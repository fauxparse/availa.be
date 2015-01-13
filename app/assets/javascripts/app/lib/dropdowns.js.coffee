# coffeelint: disable=max_line_length

backdrop = ".dropdown-backdrop"
toggle   = "[data-toggle=\"dropdown\"]"

class Dropdown
  constructor: (element) ->
    $(element).on "click.dropdown", @toggle

  toggle: (e) ->
    $this = $(this)

    return if $this.is ".disabled, :disabled"

    $parent  = getParent($this)
    isActive = $parent.hasClass("open")

    clearMenus()

    unless isActive
      relatedTarget = { relatedTarget: this }
      $parent.trigger(e = $.Event("show.dropdown", relatedTarget))

      if "ontouchstart" in document.documentElement and !$parent.closest(".navbar-nav").length
        # if mobile we use a backdrop because click events don’t delegate
        $("<div class=\"dropdown-backdrop\"/>").insertBefore(Dropdown::menu($parent)).on("click", clearMenus)

      return if e.isDefaultPrevented()

      $this
        .trigger("focus")
        .attr("aria-expanded", "true")

      $parent.toggleClass("open")

      Dropdown::positionMenu($parent)

      $parent.trigger("shown.dropdown", relatedTarget)

    false

  keydown: (e) ->
    return unless /(38|40|27)/.test(e.keyCode)

    $this = $(this)

    e.preventDefault()
    e.stopPropagation()

    return if $this.is(".disabled, :disabled")

    $parent  = getParent($this)
    isActive = $parent.hasClass("open")

    if !isActive or (isActive and e.keyCode is 27)
      $parent.find(toggle).trigger("focus") if e.which is 27
      return $this.trigger("click")

    desc = " li:not(.divider):visible a"
    $items = $parent.find("[role=\"menu\"]" + desc + ", [role=\"listbox\"]" + desc)

    return unless $items.length

    index = $items.index($items.filter(":focus"))

    if e.keyCode is 38 and index > 0
      index--
    if e.keyCode is 40 and index < $items.length - 1
      index++
    if !~index
      index = 0

    $items.eq(index).trigger("focus")

  menu: ($parent) ->
    unless clone = $parent.data("menu")
      menu = $parent.find("[role=\"menu\"], [role=\"listbox\"]").first()
      clone = menu.clone(true).hide()
      setOriginData menu, clone
      $parent.data "menu", clone
    clone

  positionMenu: ($parent) ->
    offset = $parent.offset()

    menuParent = $parent.data("append-menu")

    if menuParent is "self"
      menuParent = $parent
    menu = Dropdown::menu($parent).appendTo(menuParent or "body")
    width = $parent.outerWidth() - parseInt(menu.css("marginLeft"), 10) - parseInt(menu.css("marginRight"), 10)

    position = if menuParent
      { position: "absolute", top: 0, left: 0, right: 0 }
    else
      { position: "fixed", top: offset.top, left: offset.left, width: width }

    if menu.hasClass("dropdown-right")
      position.left = offset.left + $parent.find(toggle).outerWidth() - menu.width()

    menu.css(position).show()

  relayClick: (e) ->
    $target = $(e.target)
    if origin = $target.data("origin")
      event = $.Event("click", target: origin, relatedTarget: e.target)
      $(origin).trigger(event)

setOriginData = (source, target) ->
  children = $(source).children()
  $(target).data("origin", source)
    .children()
    .each (i) ->
      setOriginData children[i], this

clearMenus = (e) ->
  return if e?.which is 3
  $(backdrop).remove()
  $(toggle).each ->
    $this         = $(this)
    $parent       = getParent($this)
    relatedTarget = { relatedTarget: this }

    return unless $parent.hasClass("open")

    $parent.trigger(e = $.Event("hide.dropdown", relatedTarget))

    return if e.isDefaultPrevented()

    $this.attr("aria-expanded", "false")
    $parent
      .removeClass("open")
      .trigger("hidden.dropdown", relatedTarget)
    $parent.data("menu").remove()
    $parent.removeData("menu")

getParent = ($this) ->
  selector = $this.attr("data-target")

  unless selector
    selector = $this.attr("href")
    selector = selector and /#[A-Za-z]/.test(selector) and selector.replace(/.*(?=#[^\s]*$)/, "")

  $parent = selector and $(selector)

  if $parent and $parent.length
    $parent
  else
    $this.parent()

getOffset = (element) ->
  element = $(element)
  offset = element.offset()
  while (parent = element.offsetParent())[0] isnt element[0]
    parentOffset = parent.offset()
    offset.left += parentOffset.left
    offset.top += parentOffset.top
    element = parent
  offset

Plugin = (option) ->
  @each ->
    $this = $(this)
    data  = $this.data("bs.dropdown")

    $this.data("bs.dropdown", (data = new Dropdown(this))) unless data
    if typeof option is "string"
      data[option].call($this)

old = $.fn.dropdown
$.fn.dropdown             = Plugin
$.fn.dropdown.Constructor = Dropdown

$.fn.dropdown.noConflict = ->
  $.fn.dropdown = old
  this

$(document)
  .on("click.dropdown.data-api", clearMenus)
  .on("click.dropdown.data-api", ".dropdown-menu form", (e) -> e.stopPropagation())
  .on("click.dropdown.data-api", ".dropdown-menu .slider", (e) -> e.stopPropagation())
  .on("click.dropdown.data-api", toggle, Dropdown::toggle)
  .on("click.dropdown.data-api", ".dropdown-menu *", Dropdown::relayClick)
  .on("keydown.dropdown.data-api", toggle + ", [role=\"menu\"], [role=\"listbox\"]", Dropdown::keydown)
