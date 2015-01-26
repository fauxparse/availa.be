class ApplicationController < ActionController::Base
  include Pundit

  protect_from_forgery with: :exception

  respond_to :html, :json

  serialization_scope :view_context

  before_action :authenticate_user!
  around_action :set_user_time_zone!, if: :signed_in?

  # reder the default application view
  rescue_from ActionView::MissingTemplate do |exception|
    if request.format.html?
      render 'dashboards/show'
    else
      throw exception
    end
  end

  protected

  def default_serializer_options
    { root: false }
  end

  def set_user_time_zone!
    original, Time.zone = Time.zone, current_user.preferences.time_zone
    yield
    Time.zone = original
  end

  # def self.responder
  #   ResponderWithPutContent
  # end
end
