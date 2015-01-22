class InstanceSerializer < ActiveModel::Serializer
  attributes :time, :assignments

  def time
    object.time.iso8601
  end

  def assignments
    Hash.new.tap do |hash|
      object.assignments.each do |assignment|
        (hash[assignment.role_id] ||= []) << assignment.user_id
      end
    end
  end
end
