class User
  class MembershipPolicy < ApplicationPolicy
    class Scope < Struct.new(:user, :group)
      def resolve
        User.member_of(group).map do |user|
          user.membership_of(group)
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
end
