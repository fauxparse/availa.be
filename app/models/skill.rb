class Skill
  include Mongoid::Document
  # include Mongoid::Paranoia
  extend AutoStripAttributes

  field :name, type: String
  field :plural, type: String

  belongs_to :group

  validates :name,
    presence: true,
    uniqueness: { scope: :group_id, case_sensitive: false }

  auto_strip_attributes :name, :plural, squish: true

  alias_attribute :to_s, :name

  def name
    super || I18n.translate('mongoid.defaults.skill.name')
  end

  def plural
    super || name.pluralize
  end
end
