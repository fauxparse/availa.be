class InstanceSerializer < ActiveModel::Serializer
  attributes :time

  has_many :assignments
end
