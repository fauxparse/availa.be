#= require ./section

class App.Dashboard extends App.Section
  className: "dashboard"

  init: ->
    super
    @push new App.Dashboard.Show

class App.Dashboard.Show extends App.Section.Page
  init: ->
    super
    @title I18n.t("dashboards.show.title")
