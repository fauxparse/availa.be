class App.DashboardController extends Spine.Section
  className: "dashboard"

  init: ->
    super
    @append new App.DashboardController.Show

class App.DashboardController.Show extends Spine.Section.Page
  init: ->
    super
    @title I18n.t("dashboards.show.title")
