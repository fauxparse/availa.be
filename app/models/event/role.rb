class Event::Role
  include Mongoid::Document

  field :name, type: String
  field :minimum, type: Integer, default: 0
  field :maximum, type: Integer

  belongs_to :skill
  embedded_in :event

  validates_numericality_of :minimum, greater_than_or_equal_to: 0
  validates_numericality_of :maximum, greater_than_or_equal_to: 0, if: :maximum

  alias_attribute :to_s, :name

  def name
    super || skill.name
  end

  def optional?
    minimum.zero?
  end
end
