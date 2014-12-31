class Event
  include Mongoid::Document
  include Mongoid::Timestamps::Created
  include Mongoid::Timestamps::Updated

  include OrderedAssociations

  field :name, type: String
  field :duration, type: Integer, default: 1.hour

  belongs_to :group
  belongs_to :creator, class_name: "User", inverse_of: "events"
  embeds_many :recurrences, class_name: "Event::Recurrence"
  embeds_many :roles, class_name: "Event::Role", order: :position.asc
  embeds_many :availability, class_name: "Event::Availability"

  keep_ordered :roles

  alias_attribute :to_s, :name

  def times
    recurrences.collect(&:times).flatten.sort_by(&:first)
  end

  def starts_at?(time)
    times.any? { |instance| instance.first == time }
  end

  def availability_for(user)
    availability.detect { |record| record.user == user } ||
    availability.build(user: user, available: false)
  end

end
