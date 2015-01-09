Array::rotate = (d) ->
  @slice(-d).concat @slice(0, -d)
