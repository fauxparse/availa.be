class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  respond_to :html, :json

  serialization_scope :view_context

  before_action :authenticate_user!
  around_action :set_user_time_zone!, if: :signed_in?

  # reder the default application view
  rescue_from ActionView::MissingTemplate do |exception|
    if request.format.html?
      render "dashboards/show"
    else
      throw exception
    end
  end

  rescue_from CanCan::AccessDenied do |exception|
    render file: "#{Rails.root}/public/403", formats: [:html], status: 403, layout: false
  end

protected
  def default_serializer_options
    { root: false }
  end

  def set_user_time_zone!
    original_time_zone, Time.zone = Time.zone, current_user.preferences.time_zone
    yield
    Time.zone = original_time_zone
  end

end
