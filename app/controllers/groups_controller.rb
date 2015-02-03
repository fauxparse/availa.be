class GroupsController < ApplicationController
  after_action :verify_authorized, except: :index
  after_action :verify_policy_scoped, only: :index

  def index
    respond_with policy_scope(Group)
  end

  def show
    authorize group
    respond_with group
  end

  def new
    @group = Group.new
    authorize group
    respond_with group
  end

  def preferences
    authorize group, :update?

    @preferences = current_user.membership_of(group).preferences
    @preferences.update preferences_params if request.put? || request.patch?

    respond_with @preferences
  end

  protected

  def preferences_params
    params.require(:preferences).permit(:name, :color)
  end

  def group
    @group ||= Group.find_by slug: params[:id]
  end
end
