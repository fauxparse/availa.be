class User
  include Mongoid::Document

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

  def groups
    memberships.collect(&:group)
  end

  def groups=(groups)
    self.memberships = Array(groups).collect { |g| Membership.new(group: g) }
  end
end
