class EventSerializer < ActiveModel::Serializer
  attributes :id, :group_id, :name, :recurrences

  has_many :roles, serializer: RoleSerializer

end
