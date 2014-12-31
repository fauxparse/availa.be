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
  has_many :events

  validates :name, presence: true

  def groups
    memberships.collect(&:group)
  end

  def groups=(groups)
    self.memberships = Array(groups).collect { |g| membership_of(g) }
  end

  def membership_of(group, admin = false)
    memberships.detect { |m| m.group == group } ||
    User::Membership.new(group: group, admin: admin)
  end

  def member_of?(group)
    membership_of(group).exists?
  end

  def admin_of?(group)
    membership_of(group).admin?
  end

  def events
    Event.where "roles.assignments.user_id" => id
  end

  def pending
    Event.where(
      "recurrences.start_date" => { :$gte => Time.now },
      "$nor" => [
        { "roles.assignments.user_id" => id },
        { "availability.user_id" => id }
      ]
    )
  end

  # https://github.com/plataformatec/devise/issues/2949
  def to_key
    id.to_s
  end
end
