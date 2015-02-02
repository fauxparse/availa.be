class MembershipSerializer < ActiveModel::Serializer
  attributes :id, :name, :admin, :skill_ids

  def id
    object.user.id
  end

  def skill_ids
    object.abilities.map(&:skill_id)
  end
end
