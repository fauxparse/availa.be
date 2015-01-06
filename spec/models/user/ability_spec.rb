require 'rails_helper'

RSpec.describe User::Ability, type: :model do
  it { is_expected.to validate_presence_of(:skill_id) }
  it { is_expected.to validate_uniqueness_of(:skill_id) }
end
