class User
  class Membership
    include Mongoid::Document

    embedded_in :user
    belongs_to :group
    field :admin, type: Boolean, default: false

    embeds_many :abilities, class_name: 'User::Ability'
    embeds_one :preferences,
      class_name: 'User::Membership::Preferences',
      autobuild: true

    validates_presence_of :group_id
    validates_uniqueness_of :group_id

    def exists?
      !new_record?
    end

    def name
      preferences.name || user.name
    end

    def name=(value)
      value = nil if value.blank?
      preferences.name = value
    end

    def skill_ids
      abilities.collect(&:id)
    end

    def skill_ids=(ids)
      abilities.keep_if { |a| ids.include? a.skill_id.to_s }
      ids.each do |id|
        abilities.detect { |a| a.skill_id.to_s == id.to_s } ||
          abilities.build(skill_id: id)
      end
    end
  end
end
