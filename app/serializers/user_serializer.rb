class UserSerializer < ActiveModel::Serializer
  attributes :id, :name

  delegate :current_user, to: :scope

  def attributes(*attrs)
    super.tap do |data|
      data[:id] = object.id.to_s

      if object == current_user
        data[:email] = object.email
        data[:preferences] = object.preferences.as_json.except("_id")
      end
    end
  end
end
