Array::rotate = (d) ->
  @slice(-d).concat @slice(0, -d)

Array::toSentence = ->
  words = I18n.t("support.array.words_connector")
  two = I18n.t("support.array.two_words_connector")
  last = I18n.t("support.array.last_word_connector")

  switch @length
    when 0 then ""
    when 1 then @[0].toString()
    when 2 then "#{@[0]}#{two}#{@[1]}"
    else @slice(0, -1).join(words) + last + @slice(-1).join("")
