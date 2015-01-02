class Event
  include Mongoid::Document
  include Mongoid::Timestamps::Created
  include Mongoid::Timestamps::Updated

  include OrderedAssociations

  field :name, type: String
  field :duration, type: Integer, default: 1.hour
  field :starts_at, type: Time
  field :ends_at, type: Time

  belongs_to :group, index: true
  belongs_to :creator, class_name: "User", inverse_of: "events"
  embeds_many :recurrences, class_name: "Event::Recurrence"
  embeds_many :roles, class_name: "Event::Role", order: :position.asc
  embeds_many :availability, class_name: "Event::Availability"

  keep_ordered :roles

  alias_attribute :to_s, :name

  validates_presence_of :name, :group_id

  before_save :cache_start_and_end_times

  index({ starts_at: 1, ends_at: 1, creator_id: 1, "availability.user_id" => 1, "roles.assignments.user_id" => 1 }, { sparse: true })

  scope :in_range, ->(start_time, end_time) { where Event::Criteria.in_range(start_time, end_time) }
  scope :for_user, ->(user) { where Event::Criteria.user(user) }
  scope :pending_for_user, ->(user) { where Event::Criteria.pending(user) }
  scope :assigned_to_user, ->(user) { where Event::Criteria.assigned_to(user) }
  scope :with_user_available, ->(user) { where Event::Criteria.available(user) }

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

protected
  def cache_start_and_end_times
    all_times = times
    self.starts_at = all_times.first.try(:first)
    self.ends_at = all_times.last.try(:last)
  end

end