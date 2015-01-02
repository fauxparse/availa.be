class UsersController < ApplicationController
  respond_to :html, :json

  def current
    respond_with current_user
  end

  def index
    respond_with User.neighbors_of(current_user)
  end
end
