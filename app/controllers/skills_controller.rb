class SkillsController < ApplicationController
  before_action :authenticate_user!

  after_action :verify_authorized, except: :index
  after_action :verify_policy_scoped, only: :index

  def index
    @skills = policy_scope(group)
    respond_with @skills
  end

  def new
    @skill = group.skills.build name: params[:name]
    authorize @skill
    respond_with @skill, status: @skill.valid? ? :ok : :unprocessable_entity
  end

  def create
    @skill = group.skills.build skill_params
    authorize @skill
    respond_with @skill.saved
  end

  protected

  def group
    @group ||=
      (Group.find_by(slug: params[:group_id]) if params[:group_id].present?)
  end

  def skill_params
    params.require(:skill).permit(:name, :plural)
  end

  def policy_scope(group)
    @_policy_scoped = true
    @policy || SkillPolicy::Scope.new(pundit_user, group).resolve
  end
end
