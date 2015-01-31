class Group
  include Mongoid::Document
  include Stringex::ActsAsUrl

  field :name, type: String

  has_many :events
  has_many :skills

  include Sluggable

  alias_attribute :to_s, :name

  after_create :create_default_skill

  def users
    User.where(:"memberships.group_id" => id)
  end

  def user_ids
    users.only(:id).map(&:id)
  end

  def admins
    users.where(:"memberships.admin" => true)
  end

  protected

  def create_default_skill
    skills.create name: I18n.translate('mongoid.defaults.skill.name')
  end
end
