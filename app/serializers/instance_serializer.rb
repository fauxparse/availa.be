class InstanceSerializer < ActiveModel::Serializer
  attributes :time

  has_many :assignments

  def time
    object.time.iso8601
  end
end
