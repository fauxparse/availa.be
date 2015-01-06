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
    embeds_many :assignments, class_name: 'Event::Assignment'

    validates_numericality_of :minimum, greater_than_or_equal_to: 0
    validates_numericality_of :maximum,
      greater_than_or_equal_to: 0,
      if: :maximum?
    validates_each :count, if: :maximum? do |record, attr, value|
      if value > record.maximum
        record.errors.add(attr, "can’t be more than #{record.maximum}")
      end
    end

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

    def count
      assignments.length
    end

    def satisfied?
      count >= minimum
    end

    def full?
      maximum? && (count >= maximum)
    end
  end
end
