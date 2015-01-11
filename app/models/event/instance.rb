class Event::Instance
  include Mongoid::Document

  field :time, type: Time
  embedded_in :event
  embeds_many :assignments, class_name: 'Event::Assignment' do
    def for_role(role)
      detect { |assignment| assignment.role == role } ||
        build(role: role)
    end
  end

  validates_uniqueness_of :time

  def <=>(another)
    time <=> another.time
  end

  def assign(user, role)
    assignments.for_role(role).assign user
  end

  def assigned?(user, role = nil)
    assignments.any? do |a|
      (role.nil? || a.role == role) && a.assigned?(user)
    end
  end
end
