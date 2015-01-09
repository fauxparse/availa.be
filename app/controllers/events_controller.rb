class EventsController < ApplicationController
  before_action :authenticate_user!

  def index
    respond_with current_user.events
  end

  def new
  end

  def edit
    respond_with @event
  end
end
