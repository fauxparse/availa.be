class Event
  class Instance
    include Mongoid::Document

    field :time, type: Time
    field :availability, type: Hash, default: -> { {} }
    field :assignments, type: Array, default: -> { [] }
    embedded_in :event

    validates_uniqueness_of :time

    def <=>(other)
      time <=> other.time
    end

    def assign(user, role)
      unless assigned? user, role
        assignments_for(role) << user.id
      end
    end

    def assign!(user, role)
      assign user, role
      save
    end

    def assigned?(user, role = nil)
      assignments_for(role).include? user.id
    end

    def assignments=(values)
      values.each_pair do |role_id, user_ids|
        ids = user_ids.map { |id| BSON::ObjectId.from_string(id) }
        assignments_for(role_id).clear.concat(ids)
      end
    end

    def availability=(values)
      values.each_pair do |user_id, available|
        set_availability_for(user_id, available)
      end
    end

    def set_availability_for(user, available)
      id = (user.try(:id) || user).to_s
      write_attribute :availability, {} if availability.nil?

      if available.nil?
        self.availability.delete id
      else
        self.availability[id] = available
      end
    end

    def has_available?(user)
      availability_for(user) == true
    end

    def patch(attrs)
      assign_attributes attrs
    end

    protected

    def assignments_for(role)
      write_attribute :assignments, [] if assignments.nil?
      id = role.try(:id) || BSON::ObjectId.from_string(role)
      object = assignments.detect { |o| o[:role_id] == id } ||
        { role_id: id, user_ids: [] }.tap { |o| assignments << o }
      object[:user_ids]
    end

    def availability_for(user)
      id = (user.try(:id) || user).to_s
      availability[id]
    end
  end
end
