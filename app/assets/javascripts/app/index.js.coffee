#= require_tree ./lib
#= require_self
#= require_tree ./models
#= require_tree ./controllers
#= require_tree ./views

class App extends Spine.Controller
  constructor: ->
    super

    # Initialize controllers:
    #  @append(@items = new App.Items)
    #  ...

    Spine.Route.setup()

window.App = App
