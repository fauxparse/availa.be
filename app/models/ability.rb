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

    can :manage, Event do |event|
      user.member_of? event.group
    end
    can :create, Event
  end
end
