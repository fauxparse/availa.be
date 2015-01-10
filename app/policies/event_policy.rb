class EventPolicy < ApplicationPolicy
  class Scope < Struct.new(:user, :scope)
    def resolve
      scope
    end
  end

  def show?
    user.member_of? record.group
  end

  def create?
    user.admin_of? record.group
  end

  def update?
    user.admin_of? record.group
  end
end
