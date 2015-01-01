require 'rails_helper'

RSpec.describe User::Membership, :type => :model do
  it { is_expected.to validate_presence_of(:group_id) }
  it { is_expected.to validate_uniqueness_of(:group_id) }
end
