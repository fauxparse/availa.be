class EventSerializer < ActiveModel::Serializer
  attributes :id, :group_id, :name, :recurrences
end
