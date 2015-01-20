$ ->
  $(document).on "tap", ".tabs a", (e) ->
    e.preventDefault()
    $(e.target).closest("a").
      closest("li").addClass("active").siblings().removeClass("active").end()
