class EventsController < ApplicationController
  wrap_parameters include: [:name, :recurrences]
  before_action :authenticate_user!

  after_action :verify_authorized, except: :index
  after_action :verify_policy_scoped, only: :index

  def index
    respond_with policy_scope(Event)
  end

  def new
    @event = group.events.build(group_id: params[:group_id])
    authorize event
  end

  def create
    @event = group.events.build(group_id: params[:group_id])
    authorize event
    @event.save
    respond_with event
  end

  def show
    authorize event
    respond_with event
  end

  def edit
    authorize event
    respond_with event
  end

  protected

  def group
    @group ||= Group.find_by(slug: params[:group_id])
  end

  def event
    @event ||= group.events.find(params[:id])
  end

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
