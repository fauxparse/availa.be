class EventsController < ApplicationController
  before_action :authenticate_user!

  def index
    respond_with current_user.events
  end
end
