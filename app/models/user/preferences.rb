class User::Preferences
  include Mongoid::Document

  embedded_in :user

  field :time_zone, type: String, default: "UTC"
end
