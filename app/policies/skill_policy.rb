class SkillPolicy < ApplicationPolicy
  class Scope < Struct.new(:user, :group)
    def resolve
      if group.present?
        group.skills
      else
        Skill.all
      end
    end
  end

  def show?
    true
  end

  def create?
    true
  end

  def update?
    true
  end
end
