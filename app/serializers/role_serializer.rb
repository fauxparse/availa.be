class RoleSerializer < ActiveModel::Serializer
  attributes :id, :skill_id, :name, :plural, :minimum, :maximum

  def name
    object.send :read_attribute, :name
  end

  def plural
    object.send :read_attribute, :plural
  end

  def maximum
    object.send :read_attribute, :maximum
  end
end
