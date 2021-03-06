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

    # rubocop:disable Metrics/MethodLength
    def self.user(user)
      {
        :$and => [
          { :group_id.in => user.memberships.collect(&:group_id) },
          {
            :$or => [
              owner(user),
              pending(user),
              assigned_to(user),
              available(user)
            ]
          }
        ]
      }
    end
    # rubocop:enable Metrics/MethodLength

    def self.pending(user)
      {
        :starts_at.gte => Time.now,
        :"roles.skill_id".in => user.abilities.collect(&:skill_id),
        :$nor => [
          assigned_to(user),
          { "instances.availability.#{user.id}" => { :$exists => true } }
        ]
      }
    end

    def self.assigned_to(user)
      { 'instances.assignments.user_ids' => user.id }
    end

    def self.available(user)
      { "instances.availability.#{user.id}" => true }
    end

    def self.owner(user)
      { 'creator_id' => user.id }
    end
  end
end
