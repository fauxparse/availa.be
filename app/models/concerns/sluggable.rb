module Sluggable
  extend ActiveSupport::Concern

  included do
    field :slug, type: String

    acts_as_url :name, url_attribute: :slug

    validates :name, presence: true
    validates :slug,
      presence: true,
      uniqueness: { case_sensitive: false }
  end
end
