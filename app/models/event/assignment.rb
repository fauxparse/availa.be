class Event
  class Assignment
    include Mongoid::Document

    field :role_id, type: BSON::ObjectId
    field :user_ids, type: Array, default: -> { [] }
    embedded_in :instance, class_name: 'Event::Instance'
    delegate :event, to: :instance

    def role
      event.roles.find role_id
    end

    def role=(role)
      # TODO: what if the role isn't saved yet?
      self.role_id = role.id
    end

    def users
      event.group.users.where :_id.in => user_ids
    end

    def users=(users)
      self.user_ids = users.map(&:id)
    end

    def assign(user)
      user_ids << user.id unless user_ids.include?(user.id)
    end

    def assigned?(user)
      user_ids.include? user.id
    end

    def satisfied?
      count >= role.minimum
    end

    def full?
      role.maximum? && count >= role.maximum
    end

    def count
      user_ids.length
    end
  end
end
