class Event
  class Instance
    include Mongoid::Document

    field :time, type: Time
    embedded_in :event
    embeds_many :assignments, class_name: 'Event::Assignment' do
      def for_role(role)
        id = role.try(:id) || role
        detect { |a| a.role_id.to_s == id.to_s } || build(role_id: id)
      end
    end
    embeds_many :availability, class_name: 'Event::Availability' do
      def for_user(user)
        id = user.try(:id) || user
        detect { |a| a.user_id.to_s == id.to_s } ||
          build(user_id: id, available: false)
      end
    end

    validates_uniqueness_of :time

    def <=>(other)
      time <=> other.time
    end

    def assign(user, role)
      assignments.for_role(role).assign user
    end

    def assigned?(user, role = nil)
      assignments.any? do |a|
        (role.nil? || a.role == role) && a.assigned?(user)
      end
    end

    def assignments=(values)
      values.each_pair do |role_id, user_ids|
        Rails.logger.info [role_id, user_ids].inspect.red
        assignments.for_role(role_id).user_ids = user_ids.map do |id|
          BSON::ObjectId.from_string(id)
        end
      end
    end

    def availability=(values)
      availability.delete_if do |a|
        id = a.user_id.to_s
        values.key?(id) && values[id].nil?
      end

      values.each_pair do |user_id, available|
        availability.for_user(user_id).available = available
      end
    end

    def patch(hash)
      self.availability = hash[:availability] || {}
      self.assignments = hash[:assignments] || {}
    end

    protected

    def process_relations
      # this was stopping availability from saving
      pending_relations.each_pair do |name, value|
        send("#{name}=", value)
      end
    end
  end
end
