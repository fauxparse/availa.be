class EventSerializer < ActiveModel::Serializer
  attributes :id, :group_id, :name, :recurrences, :availability

  has_many :roles, serializer: RoleSerializer
  has_many :instances, serializer: InstanceSerializer

  def availability
    Hash.new.tap do |availability|
      object.availability.each do |record|
        availability[record.user_id] = record.times
      end
    end
  end

  def include_assignments?
    %w(show edit update).include? scope.try(:action_name)
  end
end
