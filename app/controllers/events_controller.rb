class EventsController < ApplicationController
  wrap_parameters include: [:name, :recurrences, :roles, :instances]
  before_action :authenticate_user!

  after_action :verify_authorized, except: [:index, :calendar]
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

  def calendar
  end

  protected

  def group
    @group ||= Group.find_by(slug: params[:group_id])
  end

  def event
    @event ||= group.events.find(params[:id])
  end

  def event_params
    params
      .require(:event)
      .permit(
        :name,
        recurrences: recurrences_params,
        roles: roles_params,
        instances: instances_params
      )
  end

  def recurrences_params
    [
      :start_date,
      :end_date,
      :start_time,
      :end_time,
      { weekdays: [] },
      :time_zone
    ]
  end

  def roles_params
    [
      :id,
      :minimum,
      :maximum,
      :name,
      :plural,
      :skill_id,
      :position
    ]
  end

  def instances_params
    [
      :id,
      :time,
      { :assignments => role_keys },
      { :availability => id_keys }
    ]
  end

  def role_keys
    event.roles.reduce({}) { |h, r| h[r.id.to_s] = []; h }
  end

  def id_keys
    @_id_keys ||= if event.group?
      event.group.users.map { |u| u.id.to_s }
    else
      []
    end
  end

  def policy_scope(group)
    @_policy_scoped = true
    @policy || EventPolicy::Scope.new(pundit_user, group).resolve
  end
end
