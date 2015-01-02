class App.DashboardController extends Spine.Section
  className: "dashboard"

  init: ->
    super
    @title I18n.t("dashboards.show.title")
