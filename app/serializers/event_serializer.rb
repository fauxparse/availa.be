class EventSerializer < ActiveModel::Serializer
  attributes :id, :name, :recurrences
end
