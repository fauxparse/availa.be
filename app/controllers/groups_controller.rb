class GroupsController < ApplicationController
  load_resource find_by: :slug
  authorize_resource

  def index
    respond_with current_user.groups
  end

  def show
    respond_with @group
  end

  def new
    respond_with @group
  end

  def preferences
    @preferences = current_user.membership_of(@group).preferences
    if request.put? or request.patch?
      @preferences.update preferences_params
    end
    respond_with @preferences
  end

protected
  def preferences_params
    params.require(:preferences).permit(:color)
  end
end
