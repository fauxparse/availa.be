class Ability
  include CanCan::Ability

  def initialize(user)
    can [:read, :create], Group
    can :manage, Group do |group|
      user.admin_of? group
    end
    cannot :preferences, Group do |group|
      !user.member_of? group
    end
  end
end
