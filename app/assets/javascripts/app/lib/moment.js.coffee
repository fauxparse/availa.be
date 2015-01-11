moment().range().constructor::toString = ->
  attrs =
    sd: @start.format("D")
    sm: @start.format("MMM")
    sy: @start.format("YYYY")
    ed: @end.format("D")
    em: @end.format("MMM")
    ey: @end.format("YYYY")
  for period in ["day", "month", "year"]
    if @start.isSame(@end, period)
      return I18n.t("moment.range.same_#{period}", attrs)
  I18n.t("moment.range.else", attrs)
