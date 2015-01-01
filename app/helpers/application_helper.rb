module ApplicationHelper
  def icon(icon)
    content_tag :i, nil, class: "icon md md-#{icon}"
  end

  def json_for(target, options = {})
    options[:scope] ||= self
    options[:url_options] ||= url_options
    target.active_model_serializer.new(target, options).to_json
  end
end
