class GroupSerializer < ActiveModel::Serializer
  attributes :id, :name, :slug

  delegate :current_user, to: :scope

  def attributes
    membership = current_user.membership_of(object)

    super.tap do |data|
      data[:admin] = membership.admin?
      data[:preferences] = membership.preferences.as_json.except('_id')
    end
  end
end
