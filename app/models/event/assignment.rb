class Event::Assignment
  include Mongoid::Document

  belongs_to :user
  embedded_in :role, class_name: "User::Role"

  validates_uniqueness_of :user_id
end
