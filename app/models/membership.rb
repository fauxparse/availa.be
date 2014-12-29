class Membership
  include Mongoid::Document

  embedded_in :user
  belongs_to :group
  field :admin, type: Boolean, default: false

  validates_uniqueness_of :group_id

  def exists?
    !new_record?
  end
end
