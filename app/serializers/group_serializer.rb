class GroupSerializer < ActiveModel::Serializer
  attributes :id, :name, :slug, :members

  has_many :skills
  has_many :members, serializer: MembershipSerializer

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

  def members
    object.users.map { |user| user.membership_of(object) }
  end

  def include_members?
    %w(show edit update).include? scope.try(:action_name)
  end
end
