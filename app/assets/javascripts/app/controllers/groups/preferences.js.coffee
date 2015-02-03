#= require ../groups

class App.Groups.Preferences extends App.Section.Page
  elements:
    "header": "header"

  events:
    "tap,click .color": "chooseColor"
    "input [name=name]": "changeDisplayName"
    "change [name=skill_ids]": "toggleSkill"

  init: ->
    super
    @el.addClass "group-preferences"

  load: (params) ->
    @el.addClass("loading").on("scroll", @scroll)
    @group = App.Group.findByAttribute "slug", params.group_id
    @render()
    @group.on("change", @render)
    App.Group.on "ajaxSuccess", @loaded
    App.Group.fetch { id: @group.id }, { url: @group.url() }

  loaded: =>
    setTimeout =>
      if App.Group.exists @group.id
        @group = App.Group.find @group.id
        @member = @group.members().find(App.User.current().id)
        @html @view("groups/preferences")(group: @group, member: @member)
        @el.removeClass "loading"
        App.Group.off "ajaxSuccess", @loaded
        @_loaded = true
    , 0

  render: ->
    if @group
      @title I18n.t("groups.preferences.title", group: @group.name())
      @$("header [rel=back]").attr("href", @group.url())

  scroll: =>
    top = @el.scrollTop()
    @header.toggleClass("floating", !!top)
      .css(y: top)

  chooseColor: (e) ->
    color = $(e.target).closest(".color")
      .addClass("active")
      .siblings(".active").removeClass("active").end()
      .attr("color")
    @group.preferences { color }

  changeDisplayName: (e) ->
    name = @$("#user_name").val() || ""
    @group.preferences { name }
    @member.name(name || App.User.current().name)

  toggleSkill: (e) ->
    @member.skill $(e.target).val(), e.target.checked
    @save()

  save: ->
    clearTimeout @_timeout
    @_timeout = setTimeout =>
      @member.save()
    , 1500
