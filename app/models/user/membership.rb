class User::Membership
  include Mongoid::Document

  embedded_in :user
  belongs_to :group
  field :admin, type: Boolean, default: false

  embeds_many :abilities, class_name: "User::Ability"
  embeds_one :preferences, class_name: "User::Membership::Preferences"

  before_validation :build_preferences, unless: :preferences?
  
  validates_presence_of :group_id
  validates_uniqueness_of :group_id

  def exists?
    !new_record?
  end
end
