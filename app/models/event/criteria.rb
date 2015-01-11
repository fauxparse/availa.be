class Event
  module Criteria
    def self.upcoming
      { :ends_at.gt => Time.now }
    end

    def self.in_range(start_time, end_time)
      {
        :starts_at.lte => end_time,
        :$or => [
          { ends_at: nil },
          { :ends_at.gte => start_time }
        ]
      }
    end

    def self.user(user)
      {
        :group_id.in => user.memberships.collect(&:group_id),
        :$or => [
          owner(user),
          pending(user),
          assigned_to(user),
          available(user)
        ]
      }
    end

    def self.pending(user)
      {
        :starts_at.gte => Time.now,
        :"roles.skill_id".in => user.abilities.collect(&:skill_id),
        :$nor => [
          { 'roles.assignments.user_id' => user.id },
          { 'availability.user_id' => user.id }
        ]
      }
    end

    def self.assigned_to(user)
      { 'roles.assignments.user_id' => user.id }
    end

    def self.available(user)
      { 'availability.user_id' => user.id }
    end

    def self.owner(user)
      { 'creator_id' => user.id }
    end
  end
end
