class EventsController < ApplicationController
  wrap_parameters include: [:name, :recurrences, :roles]
  before_action :authenticate_user!

  after_action :verify_authorized, except: :index
  after_action :verify_policy_scoped, only: :index

  def index
    @events = policy_scope(group)
    respond_with @events.upcoming
  end

  def new
    @event = group.events.build
    authorize event
  end

  def create
    @event = group.events.build(event_params)
    authorize event
    respond_with event.saved
  end

  def show
    authorize event
    respond_with event
  end

  def edit
    authorize event
    respond_with event
  end

  def update
    authorize event
    respond_with event.updated_with(event_params)
  end

  def destroy
    respond_with event.destroyed
  end

  protected

  def group
    @group ||= if params[:group_id].present?
      Group.find_by(slug: params[:group_id])
    else
      nil
    end
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
        ],
        :roles => [
          :id,
          :minimum,
          :maximum,
          :name,
          :plural,
          :skill_id,
          :position
        ]
      )
  end

  def policy_scope(group)
    @_policy_scoped = true
    @policy || EventPolicy::Scope.new(pundit_user, group).resolve
  end
end
