class App.Group extends Spine.Model
  @configure "Group", "name", "slug", "admin", "preferences"
  @extend Spine.Model.Ajax

  @hasMany "skills", "App.Skill"

  toString: -> @name

  url: -> App.Group.url() + "/" + @toParam()

  toParam: -> @slug

  load: (attrs) ->
    @_loading = true
    super
    @_loading = false

  preferences: (preferences) ->
    if preferences?
      @_preferences = $.extend @_preferences or {}, preferences
      unless @_loading
        Spine.Ajax.disable => @save()
        @savePreferences()
    @_preferences

  color: ->
    if @preferences().color
      Color[@preferences().color]
    else
      Color.of @name

  savePreferences: ->
    clearTimeout @_save
    @_save = setTimeout =>
      $.ajax
        url: @url() + "/preferences"
        type: "put"
        contentType: "application/json"
        dataType: "json"
        data: JSON.stringify(preferences: @preferences())
    , 250

  @comparator: (a, b) ->
    a.name.toLocaleLowerCase().localeCompare b.name.toLowerCase()
