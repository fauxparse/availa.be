class User::Membership::Preferences
  include Mongoid::Document

  embedded_in :membership, class_name: "User::Membership"

  delegate :user, to: :membership

  field :color, type: String
end
