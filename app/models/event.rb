class Event
  include Mongoid::Document
  include Mongoid::Timestamps::Created
  include Mongoid::Timestamps::Updated

  field :name, type: String
  field :duration, type: Integer, default: 1.hour

  belongs_to :group
  belongs_to :creator, class_name: "User", inverse_of: "events"
  embeds_many :recurrences, class_name: "Event::Recurrence"
  embeds_many :roles, class_name: "Event::Role"

  alias_attribute :to_s, :name

  def times
    recurrences.collect(&:times).flatten.sort_by(&:first)
  end

end
