class User
  include Mongoid::Document
  include Mongoid::Paranoia # never really delete users

  devise :database_authenticatable,
    :registerable,
    :recoverable,
    :rememberable,
    :trackable,
    :validatable

  field :name, type: String
  field :email, type: String
  field :encrypted_password, type: String

  validates :name, presence: true

  embeds_many :memberships
  has_many :events

  def groups
    memberships.collect(&:group)
  end

  def groups=(groups)
    self.memberships = Array(groups).collect { |g| membership_of(g) }
  end

  def membership_of(group, admin = false)
    memberships.detect { |m| m.group == group } ||
    Membership.new(group: group, admin: admin)
  end

  def member_of?(group)
    membership_of(group).exists?
  end

  def admin_of?(group)
    membership_of(group).admin?
  end
end
