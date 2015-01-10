class GroupPolicy < ApplicationPolicy
  class Scope < Struct.new(:user, :scope)
    def resolve
      scope.where :id.in => user.memberships.map(&:id)
    end
  end

  def create?
    true
  end

  def update?
    user.admin_of? record
  end
end
