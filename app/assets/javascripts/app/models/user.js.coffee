class App.User extends Spine.Model
  @configure "User", "name", "email"
  @extend Spine.Model.Ajax

  @fetchCurrent: ->
    promise = $.Deferred()
    if @_current
      promise.resolve @_current
    else
      $.getJSON("/users/current")
        .done (data) =>
          @one "refresh", (records) =>
            promise.resolve records[0]
          @refresh data
    promise
