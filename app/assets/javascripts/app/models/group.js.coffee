class App.Group extends Spine.Model
  @configure "Group", "name", "slug", "preferences"

  color: ->
    if @preferences.color
      Color[@preferences.color]
    else
      Color.of @name

  @comparator: (a, b) ->
    a.name.toLocaleLowerCase().localeCompare b.name.toLowerCase()
