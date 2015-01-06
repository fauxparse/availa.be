class User
  class Membership
    class Preferences
      include Mongoid::Document

      embedded_in :membership, class_name: 'User::Membership'

      delegate :user, to: :membership

      field :color, type: String
    end
  end
end
