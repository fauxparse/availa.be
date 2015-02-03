class MembersController < ApplicationController
  wrap_parameters include: [:name, :email, :admin, :skill_ids, :preferences]
  before_action :authenticate_user!

  after_action :verify_authorized, except: :index
  after_action :verify_policy_scoped, only: :index

  def update
    authorize member
    member.update member_params
    respond_with member
  end

  protected

  def group
    @group ||= Group.find_by(slug: params[:group_id])
  end

  def user
    @user ||= User.member_of(group).find(params[:id])
  end

  def member
    @member ||= user && user.membership_of(group)
  end

  def member_params
    keys = [:name, { skill_ids: [] }]
    keys << :admin if current_user.admin_of?(group) and member != current_user
    keys << :preferences if member == current_user
    params.require(:member).permit(*keys)
  end

  def policy_scope(group)
    @_policy_scoped = true
    @policy || User::MembershipPolicy::Scope.new(pundit_user, group).resolve
  end
end
