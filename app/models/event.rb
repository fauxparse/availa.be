class Event
  include Mongoid::Document
  include Mongoid::Timestamps::Created
  include Mongoid::Timestamps::Updated

  field :name, type: String
  field :duration, type: Integer, default: 1.hour

  belongs_to :group
  belongs_to :creator, class_name: "User", inverse_of: "events"
  embeds_many :recurrences, class_name: "Event::Recurrence"

  def times
    recurrences.collect(&:times).flatten.sort_by(&:first)
  end

end
