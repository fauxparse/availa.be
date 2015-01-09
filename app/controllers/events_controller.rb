class EventsController < ApplicationController
  wrap_parameters include: [:name, :recurrences]
  before_action :authenticate_user!
  load_and_authorize_resource

  def index
    respond_with current_user.events
  end

  def new
  end

  def create
    @event = Event.create event_params
    respond_with @event
  end

  def show
    respond_with @event
  end

  def edit
    respond_with @event
  end

  protected

  def event_params
    params.
      require(:event).
      permit(
        :name,
        :recurrences => [
          :start_date,
          :end_date,
          :start_time,
          :end_time,
          { :weekdays => [] },
          :time_zone
        ]
      ).
      merge(group: Group.first)
  end
end
