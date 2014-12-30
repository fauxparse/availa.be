class User::Ability
  include Mongoid::Document

  belongs_to :skill
  embedded_in :membership, class_name: "User::Membership"

  validates :skill_id, presence: true, uniqueness: true
end
