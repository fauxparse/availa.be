class UserSerializer < ActiveModel::Serializer
  attributes :id, :name
  has_many :groups

  delegate :current_user, to: :scope

  def current_user?
    object == current_user
  end

  def attributes(*attrs)
    super.tap do |data|
      data[:id] = object.id.to_s

      if current_user?
        data[:email] = object.email
        data[:preferences] = object.preferences.as_json.except('_id')
      end
    end
  end

  def include_groups?
    current_user?
  end
end
