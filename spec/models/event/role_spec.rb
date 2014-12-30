require 'rails_helper'

RSpec.describe Event::Role, :type => :model do
  subject(:role) { event.roles.build skill: skill }
  let(:group) { FactoryGirl.create :group }
  let(:event) { FactoryGirl.create :event, group: group }
  let(:skill) { FactoryGirl.create :skill, group: group }

  context "without a minimum" do
    it { is_expected.to be_optional }
  end

  context "with a minimum" do
    before do
      role.minimum = 1
    end

    it { is_expected.not_to be_optional }
  end

  describe "#name" do
    context "without a name" do
      it "uses the name of the associated skill" do
        expect(role.name).to eq(role.skill.name)
      end
    end

    context "with a name" do
      before do
        role.name = "fish"
      end

      it "uses its own name" do
        expect(role.name).to eq("fish")
      end
    end
  end

end
