module Sluggable
  extend ActiveSupport::Concern

  included do
    field :slug, type: String

    acts_as_url :name, url_attribute: :slug

    validates :name, presence: true
    validates :slug,
      presence: true,
      uniqueness: { case_sensitive: false }

    alias_attribute :to_param, :slug
  end
end
