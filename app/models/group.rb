class Group
  include Mongoid::Document
  include Stringex::ActsAsUrl

  field :name, type: String

  include Sluggable

  def users
    User.where(:"memberships.group_id" => id)
  end

  def admins
    users.where(:"memberships.admin" => true)
  end
end
