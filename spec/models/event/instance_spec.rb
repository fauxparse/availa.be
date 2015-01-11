require 'rails_helper'

RSpec.describe Event::Instance, :type => :model do
  subject(:instance) { event.instances.first }
  let(:role) { event.roles.build skill: skill }
  let(:group) { FactoryGirl.create :group }
  let(:event) { FactoryGirl.create :event, group: group }
  let(:skill) { FactoryGirl.create :skill, group: group }

  [:dumbledore, :harry, :hermione, :ron].each do |user|
    let(user) { FactoryGirl.create user }
  end

  it { is_expected.to validate_uniqueness_of(:time) }


end
