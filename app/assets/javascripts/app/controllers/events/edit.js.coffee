#= require ../events
#= require ./show

class App.Events.Edit extends App.Events.Show
  back: "/events"

  elements:
    ".roles": "roles"
    "header [rel=save]": "saveButton"

  events:
    "input [name=name]": "nameChanged"
    "change [rel=date]": "dateChanged"
    "change [rel=time]": "dateChanged"
    "change [name=weekdays]": "weekdaysChanged"
    "tap [rel=add-role]": "addRole"
    "tap .role [rel=delete]": "deleteRole"
    "sorted .roles": "rolesSorted"
    "shown.dropdown [rel=limits]": "limitsShown"
    "click .role [rel=skill] .dropdown-menu": "skillMenuClicked"
    "tap header [rel=save]": "save"

  init: ->
    super
    @el.
      removeClass("show-event").
      addClass("edit-event")
    App.Skill.on "change", @skillsChanged

    @on "release", =>
      App.Skill.off "change", @skillsChanged

  load: (params) ->
    unless params.id
      @title I18n.t("events.new.title")
      @event = new App.Event(group_id: params.group_id)

    super

    @back = params.back || "/groups/#{params.group_id}/events/#{params.id}"
    @$("header [rel=back]").attr href: @back

    if params.id
      @event_id = params.id
      @el.addClass "loading"
      url = "/groups/#{params.group_id}/events/#{params.id}"
      App.Event.fetch { id: @event_id }, { url }
    else
      @_loaded = true
      @render()

  render: =>
    @title I18n.t("events.edit.title", @event.name()) unless @event.isNew()
    @content.empty()
    if @_loaded
      weekdays = ([w, i] for w, i in moment.weekdaysMin()).
        rotate(-moment().startOf("week").day())
      @html @view("events/edit")(event: @event, weekdays: weekdays)
      @checkWeekdays()
      @renderRoles()

  renderHeader: ->
    @header.html @view("shared/section_header")(back: @back || "/")
    $("<button>", rel: "save").
      append($("<div>", class: "loading-spinner")).
      append($("<i>", class: "icon-done")).
      appendTo(@header)

  renderRoles: ->
    @roles.empty()
    group = @event.group()
    for role in @event.roles()
      $(@view("events/role")({ role, group })).
        data({ role }).
        appendTo(@roles)

  skillsChanged: =>
    skills = @event.group().skills().all().sort(App.Skill.comparator)
    @$("[rel=skill] .dropdown-menu").each (i, el) ->
      menu = $(el)
      menu.find(".divider").prevAll("li").remove()
      for skill in skills.reverse()
        $("<a>", href: "#", skill: skill.id).
          text(skill.plural()).
          prependTo(menu).
          wrap("<li>")

  action: ->
    if @event?.isNew()
      "new"
    else
      "edit"

  nameChanged: (e) ->
    @event.name $(e.target).val()

  dateChanged: (e) ->
    input = $(e.target)
    @event[input.attr("name")] input.val()
    @checkWeekdays()

  timeChanged: (e) ->
    input = $(e.target)
    @event[input.attr("name")] input.val()

  weekdaysChanged: (e) ->
    values = @$("[name=weekdays]:checked").
      map(-> parseInt($(this).val(), 10)).
      get()
    @event.weekdays values

  checkWeekdays: (e) ->
    d = @event.start_date().clone()
    i = 0
    valid = {}
    days = []

    while i < 7 and !d.isAfter(@event.end_date())
      valid[d.day()] = true
      d.add(1, "day")
      i++

    @$(".weekdays input").each (i, el) ->
      el = $(el)
      day = parseInt(el.val(), 10)
      if valid[day]
        el.removeAttr("disabled")
        days.push day if el.is(":checked")
      else
        el.attr("disabled", true).removeAttr("checked")

    @event.weekdays days

  addRole: (e) ->
    e.preventDefault()
    skill = @event.group().skills().first()
    @event.addRole(skill)
    @renderRoles()

  deleteRole: (e) ->
    e.preventDefault()
    row = $(e.target).closest(".role")
    @event.deleteRoleAt row.prevAll(".role").length
    row.transition({ opacity: 0 }, -> $(this).remove())

  rolesSorted: (e) ->
    @event.roles @$(".roles .role").map(-> $(this).data("role")).get()

  limitsShown: (e) ->
    row = $(e.target).closest(".role")
    role = @event.roles()[row.prevAll(".role").length]
    menu = $(e.target).data("menu")
    menu.find(".limits").text(role.range())
    slider = menu.find(".slider")
    slider.noUiSlider
      start: [role.minimum(), role.maximum() ? 1000]
      connect: true
      step: 1
      range:
        "min": 0
        "90%": 20
        "max": 1000
    slider.on "slide set", (e, [min, max])->
      role.minimum Math.floor(min)
      if max > 20
        role.maximum undefined
      else
        role.maximum Math.floor(max)
      menu.find(".limits").
        add(row.find("[rel=limits] .dropdown-toggle")).
        text(role.range())

  skillMenuClicked: (e) ->
    e.preventDefault()
    if e.relatedTarget
      item = $(e.relatedTarget)
      row = $(e.target).closest(".role")
      index = row.prevAll(".role").length

      if item.is("[rel=add-skill]")
        skill = new App.Skill(group_id: @event.group().id)
        new NewSkill({ skill }).on "skill", (skill) =>
          row.find("[rel=skill] .dropdown-toggle").text(skill.plural())
          skill.on "ajaxSuccess", (skill) =>
            @event.roles()[index].skill_id = skill.id
            @renderRoles()
      else
        skill = @event.group().skills().find(item.attr("skill"))
        @event.roles()[index].skill_id = skill.id
        row.
          find("[rel=skill] .dropdown-toggle").text(skill.plural()).end().
          find("[name=name]").attr(placeholder: skill.name()).end().
          find("[name=plural]").attr(placeholder: skill.plural()).end()

  save: (e) ->
    @el.addClass "loading"
    @saveButton.attr disabled: true

    url = if @event.isNew()
      @event.group().url() + App.Events.url()
    else
      @event.url()

    @event.on "ajaxSuccess", @saved
    @event.save url: url

  saved: =>
    @event.off "ajaxSuccess", @saved
    @el.removeClass "loading"
    @saveButton.removeAttr "disabled"

class NewSkill extends App.Dialog
  elements:
    "[name=name]": "name"
    "[name=plural]": "plural"
    "[rel=ok]": "ok"

  events:
    "click [rel='ok']": "save"
    "input [name=name]": "nameChanged"
    "input [name=plural]": "pluralChanged"

  init: ->
    super
    @el.addClass "new-skill"
    @html @view("skills/new")(skill: @skill)

  save: (e) ->
    @skill.name @name.val()
    @skill.plural @plural.val()
    @skill.save url: @url()
    @trigger "skill", @skill
    @hide()

  url: ->
    @skill.group().url() + "/skills"

  shown: =>
    super
    @nameChanged()
    @name.select()

  nameChanged: (e) ->
    clearTimeout @delay
    @delay = setTimeout @checkName, 250

  pluralChanged: (e) ->
    @_pluralChanged = true

  checkName: =>
    @ok.attr(disabled: true)
    if name = @name.val()
      @request?.abort()
      @request = $.getJSON(@url() + "/new", { name }).
        done(@allowName).
        fail(@disallowName)
    else
      @name.
        attr("invalid", true).
        nextAll(".error-message").
        text(I18n.t("mongoid.errors.skill.name.empty"))

  allowName: (data) =>
    delete @request
    @name.removeAttr("invalid").val data.name
    @plural.val data.plural unless @_pluralChanged
    @ok.removeAttr("disabled")

  disallowName: =>
    delete @request
    @name.
      attr("invalid", true).
      nextAll(".error-message").
      text(I18n.t("mongoid.errors.skill.name.taken"))
