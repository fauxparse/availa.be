require 'rails_helper'

RSpec.describe Group, type: :model do
  subject(:group) { FactoryGirl.create :group, name: 'Hogwarts' }

  it { is_expected.to validate_presence_of(:name) }

  describe '#create' do
    it 'creates its own slug' do
      expect(group.slug).to eq('hogwarts')
    end

    it 'avoids slug clashes' do
      group2 = FactoryGirl.create :group, name: group.name
      expect(group2.slug).to eq("#{group.slug}-1")
    end
  end

  describe '#users' do
    it 'returns a list of users' do
      users = [:harry, :hermione].collect do |u|
        FactoryGirl.create(u, groups: [group])
      end
      dumbledore = FactoryGirl.create(:dumbledore)

      expect(group.users).to eq(users)
      expect(group.users).not_to include(dumbledore)
    end
  end

  describe '#admins' do
    it 'returns a list of admins' do
      users = { dumbledore: true, harry: false, hermione: false }
      users.each_pair do |u, admin|
        m = User::Membership.new(group: group, admin: admin)
        FactoryGirl.create u, memberships: [m]
      end

      expect(group.admins.collect(&:name)).to eq(['Dumbledore'])
    end
  end
end
