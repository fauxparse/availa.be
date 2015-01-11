class Event
  class Role
    include Mongoid::Document

    field :name, type: String
    field :plural, type: String
    field :minimum, type: Integer, default: 0
    field :maximum, type: Integer
    field :position, type: Integer

    belongs_to :skill
    embedded_in :event

    validates_numericality_of :minimum, greater_than_or_equal_to: 0
    validates_numericality_of :maximum,
      greater_than_or_equal_to: 0,
      if: :maximum?

    alias_attribute :to_s, :name

    def name
      super ||
        skill.name
    end

    def plural
      super ||
        read_attribute(:name).try(:pluralize) ||
        skill.plural
    end

    def optional?
      minimum.zero?
    end

    def unlimited?
      !maximum?
    end
  end
end
