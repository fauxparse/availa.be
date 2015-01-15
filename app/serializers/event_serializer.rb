class EventSerializer < ActiveModel::Serializer
  attributes :id, :group_id, :name, :recurrences, :assignments

  has_many :roles, serializer: RoleSerializer

  def assignments
    Hash.new.tap do |assignments|
      object.instances.each do |instance|
        hash = {}

        object.roles.each { |r| hash[r.id] = [] }

        instance.assignments.each do |assignment|
          hash[assignment.role_id] << assignment.user_id
        end

        assignments[instance.time.to_s] = hash
      end
    end
  end

  def include_assignments?
    %w(show edit update).include? scope.try(:action_name)
  end
end
