class Group
  include Mongoid::Document
  include Stringex::ActsAsUrl

  field :name, type: String

  has_many :events
  has_many :skills

  include Sluggable

  alias_attribute :to_s, :name
  
  def users
    User.where(:"memberships.group_id" => id)
  end

  def admins
    users.where(:"memberships.admin" => true)
  end
end
