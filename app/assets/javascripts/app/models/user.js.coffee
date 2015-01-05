class App.User extends Spine.Model
  @configure "User", "name", "email"
  @extend Spine.Model.Ajax

  @current: -> @_current

  @fetchCurrent: ->
    promise = $.Deferred()
    if @_current
      promise.resolve @_current
    else
      $.getJSON("/users/current")
        .done (data) =>
          @one "refresh", (records) =>
            @_current = records[0]
            promise.resolve @_current
          App.Group.refresh data.groups
          @refresh data
    promise
