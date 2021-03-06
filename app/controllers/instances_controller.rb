class InstancesController < ApplicationController
  wrap_parameters :instance, include: [:availability, :assignments]
  before_action :authenticate_user!

  after_action :verify_authorized

  def update
    authorize event
    Rails.logger.info instance_params.inspect.green
    respond_with instance.patched(instance_params)
  end

  protected

  def group
    @group ||= Group.find_by(slug: params[:group_id])
  end

  def event
    @event ||= group.events.find(params[:event_id])
  end

  def instance
    @event.instances.for_time time
  end

  def time
    @time ||= params[:time].to_time
  end

  def instance_params
    params.require(:instance).permit(
      assignments: event_role_params,
      availability: group.user_ids.map(&:to_s)
    )
  end

  def event_role_params
    event.roles.each_with_object({}) { |i, a| a[i.id.to_s] = [] }
  end
end
