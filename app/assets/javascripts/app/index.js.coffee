#= require_tree ./lib
#= require_self
#= require_tree ./models
#= require_tree ./controllers
#= require_tree ./views

class App extends Spine.Controller
  events:
    "click a": "inPageNavigation"

  constructor: ->
    super
    @stack = new App.Stack el: "section.main"
    App.User.fetchCurrent().done @start

  start: =>
    Spine.Route.setup history: true

  inPageNavigation: (e) ->
    e.preventDefault()
    @navigate $(e.target).closest("[href]").attr("href")

window.App = App

$ -> window.app = new App el: "body"
