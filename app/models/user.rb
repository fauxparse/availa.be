class User
  include Mongoid::Document
  include Mongoid::Paranoia # never really delete users

  devise :database_authenticatable,
    :registerable,
    :recoverable,
    :rememberable,
    :validatable

  field :name, type: String
  field :email, type: String
  field :encrypted_password, type: String
  field :remember_created_at, type: Time

  embeds_many :memberships, class_name: "User::Membership"
  embeds_many :abilities, class_name: "User::Ability"
  embeds_one :preferences, class_name: "User::Preferences"
  has_many :events

  validates :name, presence: true
  validates_associated :memberships
  
  before_validation :build_preferences, unless: :preferences?

  scope :neighbors_of, ->(user) do
    where :$or => [
      { :id => user.id },
      { :"memberships.group_id".in => user.groups.collect(&:id) }
    ]
  end

  def groups
    if memberships.any?
      Array Group.find(*memberships.collect(&:group_id))
    else
      []
    end
  end

  def groups=(groups)
    self.memberships = Array(groups).collect { |g| membership_of(g) }
  end

  def membership_of(group, admin = false)
    memberships.detect { |m| m.group == group } ||
    memberships.build(group: group, admin: admin)
  end

  def member_of?(group)
    membership_of(group).exists?
  end

  def admin_of?(group)
    membership_of(group).admin?
  end

  def events
    Event.assigned_to_user(self)
  end

  def pending
    Event.pending_for_user(self)
  end

end
