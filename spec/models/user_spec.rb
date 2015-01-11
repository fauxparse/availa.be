require 'rails_helper'

RSpec.describe User, type: :model do
  subject(:user) { FactoryGirl.create :user, abilities: [ability] }
  let(:ability) { FactoryGirl.build :ability, skill: skill }
  let(:group) { FactoryGirl.create :group }
  let(:event) do
    FactoryGirl.create :event,
      group: group,
      roles: [Event::Role.new(skill: skill)],
      recurrences: [{
        start_date: Date.today + 1.year,
        end_date: Date.today + 1.year + 1.month
      }]
  end
  let(:skill) { FactoryGirl.create :skill, group: group }
  let(:role) { event.roles.first }

  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_presence_of(:email) }
  it { is_expected.to validate_uniqueness_of(:email) }

  describe '#memberships' do
    it 'keeps track of group memberships' do
      user.memberships << User::Membership.new(group: group)

      expect(user.memberships.map(&:group)).to eq([group])
    end

    it 'cannot join the same group twice' do
      2.times do
        user.memberships << User::Membership.new(group: group)
      end

      expect(user).not_to be_valid
    end
  end

  describe '#groups' do
    it 'returns a list of groups' do
      user.memberships << User::Membership.new(group: group)

      expect(user.groups).to eq([group])
    end
  end

  describe '#groups=' do
    it 'sets a list of groups' do
      user.groups = [group]

      expect(user.groups).to eq([group])
    end

    it 'accepts a single group' do
      user.groups = group

      expect(user.groups).to eq([group])
    end
  end

  context 'not in a group' do
    describe '#membership_of' do
      it 'does not exist' do
        expect(user.membership_of(group)).not_to exist
      end
    end

    describe '#member_of?' do
      it 'returns false' do
        expect(user.member_of?(group)).to be false
      end
    end
  end

  context 'in a group' do
    before do
      user.update groups: [group]
    end

    describe '#membership_of' do
      it 'exists' do
        expect(user.membership_of(group)).to exist
      end

      it 'has preferences' do
        expect(user.membership_of(group).preferences).to be_present
      end
    end

    describe '#member_of?' do
      it 'returns true' do
        expect(user.member_of?(group)).to be true
      end
    end

    describe '#admin_of?' do
      it 'returns false' do
        expect(user.admin_of?(group)).to be false
      end
    end
  end

  context 'as admin of a group' do
    before do
      user.update memberships: [user.membership_of(group, true)]
    end

    describe '#membership_of' do
      it 'exists' do
        expect(user.membership_of(group)).to exist
      end
    end

    describe '#member_of?' do
      it 'returns true' do
        expect(user.member_of?(group)).to be true
      end
    end

    describe '#admin_of?' do
      it 'returns true' do
        expect(user.admin_of?(group)).to be true
      end
    end
  end

  context 'assigned to an event' do
    before do
      event.instances.first.update(
        assignments: [Event::Assignment.new(user_ids: [user.id], role: role)]
      )
    end

    it 'finds the event' do
      expect(user.events).to include(event)
    end

    it 'does not show the event as pending' do
      expect(user.pending).not_to include(event)
    end
  end

  describe '#pending' do
    context 'when the event is in the past' do
      before do
        old = 1.year.ago
        event.update recurrences: [{
          start_date: Date.today - 1.year,
          end_date: Date.today - 1.year + 1.month
        }]
        event.recurrences.first.update! start_date: old, end_date: old + 1.week
      end

      it 'does not include the event' do
        expect(user.pending).not_to include event
      end
    end

    context 'when user has not given availability' do
      it 'includes the event' do
        expect(user.pending).to include event
      end
    end

    context 'when user has given availability' do
      before do
        event.availability_for(user).update(available: false)
      end

      it 'does not include the event' do
        expect(user.pending).not_to include event
      end
    end

    context "when user doesn't have the right skills" do
      before do
        user.update abilities: []
      end

      it 'does not include the event' do
        expect(user.pending).not_to include event
      end
    end
  end
end
