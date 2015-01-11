class EventPolicy < ApplicationPolicy
  class Scope < Struct.new(:user, :group)
    def resolve
      if group.present?
        if user.admin_of?(group)
          group.events
        else
          Event.for_user(user)
        end
      else
        Event.for_user(user)
      end
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
