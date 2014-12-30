class Skill
  include Mongoid::Document
  include Mongoid::Paranoia

  field :name, type: String
  field :plural, type: String

  belongs_to :group

  validates :name,
    presence: true,
    uniqueness: { scope: :group_id }

  alias_attribute :to_s, :name

  def plural
    super || name.pluralize
  end
end
