class App.Skill extends Spine.Model
  @configure "Skill", "name", "plural"
  @extend Spine.Model.Ajax

  @belongsTo "group", "App.Group"

  name: (value) ->
    @_name = value if value?
    @_name || "participant"

  plural: (value) ->
    @_plural = value if value?
    # TODO: pluralize properly
    @_plural || @name() + "s"

  toString: -> @name()

  @comparator: (a, b) ->
    a = a.toString().toLocaleLowerCase()
    b = b.toString().toLocaleLowerCase()
    a.localeCompare b
  
