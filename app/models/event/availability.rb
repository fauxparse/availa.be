class Event
  class Availability
    include Mongoid::Document
    include Mongoid::Timestamps::Created
    include Mongoid::Timestamps::Updated

    field :available, type: Boolean, default: true
    field :times, type: Array, default: -> { [] }
    belongs_to :user
    embedded_in :event

    validates_uniqueness_of :user_id

    def available_for?(time)
      available? &&
        times.include?(time) &&
        event.starts_at?(time)
    end

    def exists?
      !new_record?
    end
  end
end
