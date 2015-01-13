class GroupSerializer < ActiveModel::Serializer
  attributes :id, :name, :slug

  has_many :skills

  delegate :current_user, to: :scope

  def attributes
    membership = current_user.membership_of(object)

    super.tap do |data|
      data.merge!(
        admin: membership.admin?,
        preferences: membership.preferences.as_json.except('_id'),
        abilities: membership.abilities.map { |a| a.as_json.except('_id') }
      )
    end
  end
end
