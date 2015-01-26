class Event
  class Availability
    include Mongoid::Document
    include Mongoid::Timestamps::Created
    include Mongoid::Timestamps::Updated

    field :available, type: Boolean, default: true
    belongs_to :user
    embedded_in :instance

    validates_uniqueness_of :user_id
  end
end
