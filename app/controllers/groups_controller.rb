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
end
