require 'rails_helper'

RSpec.describe User, :type => :model do
  subject(:user) { FactoryGirl.create :user }
  let(:group) { FactoryGirl.create :group }

  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_presence_of(:email) }
  it { is_expected.to validate_uniqueness_of(:email).case_insensitive }

  describe "#memberships" do
    it "keeps track of group memberships" do
      user.memberships << Membership.new(group: group)

      expect(user.memberships.collect(&:group)).to eq([group])
    end

    it "cannot join the same group twice" do
      2.times do
        user.memberships << Membership.new(group: group)
      end

      expect(user).not_to be_valid
    end
  end

  describe "#groups" do
    it "returns a list of groups" do
      user.memberships << Membership.new(group: group)

      expect(user.groups).to eq([group])
    end
  end

  describe "#groups=" do
    it "sets a list of groups" do
      user.groups = [group]

      expect(user.groups).to eq([group])
    end

    it "accepts a single group" do
      user.groups = group

      expect(user.groups).to eq([group])
    end
  end
end
