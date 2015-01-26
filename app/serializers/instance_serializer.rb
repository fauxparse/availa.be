class InstanceSerializer < ActiveModel::Serializer
  attributes :time, :assignments, :availability

  def time
    object.time.iso8601
  end

  def assignments
    Hash.new.tap do |hash|
      object.assignments.each do |assignment|
        hash[assignment.role_id] = assignment.user_ids
      end
    end
  end

  def availability
    Hash.new.tap do |hash|
      object.availability.each do |a|
        hash[a.user_id] = a.available
      end
    end
  end
end
