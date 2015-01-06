module ApplicationHelper
  def icon(icon)
    content_tag :i, nil, class: "icon icon-#{icon}"
  end

  def json_for(target, options = {})
    options[:scope] ||= self
    options[:url_options] ||= url_options
    target.active_model_serializer.new(target, options).to_json
  end

  def navigation_item(item, link)
    content_tag :li, class: 'list-item' do
      link_to link, class: 'primary-action' do
        concat icon(t("#{item}.icon"))
        concat content_tag(:div, class: :text) {
          content_tag :div, t("#{item}.link"), class: :line
        }
      end
    end
  end
end
