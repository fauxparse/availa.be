require 'rails_helper'

RSpec.describe Event::Assignment, :type => :model do
  it { is_expected.to validate_uniqueness_of(:user_id) }
end
