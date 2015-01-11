require 'rails_helper'

RSpec.describe Event, type: :model do
  subject(:event) { FactoryGirl.create :event, group: group }
  let(:group) { FactoryGirl.create :group }
  let(:user) do
    FactoryGirl.create :user, memberships: [User::Membership.new(group: group)]
  end

  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_presence_of(:group_id) }

  context 'for Saturdays in 2015' do
    before do
      event.update recurrences: [{
        start_date: '2015-01-01',
        end_date: '2015-12-31',
        start_time: 9.hours,
        end_time: 11.hours,
        weekdays: [6],
        time_zone: Time.zone.name
      }]
    end

    describe '#times' do
      it 'generates a list of times' do
        # http://www.convertunits.com/dates/howmany/Saturdays-in-2015
        expect(event.times.length).to eq(52)
      end
    end

    describe '#instances' do
      it 'keeps the instances up to date' do
        expect(event.instances.length).to eq(52)
      end
    end

    describe '#cache_start_and_end_times' do
      it 'caches start time' do
        expect(event.starts_at).to eq(Time.zone.local(2015, 1, 3, 9))
      end

      it 'caches end time' do
        expect(event.ends_at).to eq(Time.zone.local(2015, 12, 26, 11))
      end
    end

    describe '#in_range' do
      it 'matches a containing range' do
        events = Event.in_range(
          Time.zone.local(2014, 1, 1),
          Time.zone.local(2016, 12, 31)
        )
        expect(events).to include(event)
      end

      it 'matches a contained range' do
        events = Event.in_range(
          Time.zone.local(2015, 7, 1),
          Time.zone.local(2015, 7, 31)
        )
        expect(events).to include(event)
      end

      it 'matches a start-overlapping range' do
        events = Event.in_range(
          Time.zone.local(2014, 1, 1),
          Time.zone.local(2015, 7, 31)
        )
        expect(events).to include(event)
      end

      it 'matches an end-overlapping range' do
        events = Event.in_range(
          Time.zone.local(2015, 7, 1),
          Time.zone.local(2016, 12, 31)
        )
        expect(events).to include(event)
      end

      it 'does not match an earlier range' do
        events = Event.in_range(
          Time.zone.local(2014, 1, 1),
          Time.zone.local(2014, 12, 31)
        )
        expect(events).not_to include(event)
      end

      it 'does not match a later range' do
        events = Event.in_range(
          Time.zone.local(2016, 1, 1),
          Time.zone.local(2016, 12, 31)
        )
        expect(events).not_to include(event)
      end
    end

    describe '#for_user' do
      it 'does not include the event by default' do
        expect(Event.for_user(user)).not_to include(event)
      end

      context 'when the user is not a member of the group' do
        before do
          user.update memberships: []
        end

        it 'does not include the event' do
          expect(Event.for_user(user)).not_to include(event)
        end
      end

      context 'when the user is the creator' do
        before do
          event.update creator_id: user.id
        end

        it 'includes the event' do
          expect(Event.for_user(user)).to include(event)
        end
      end
    end
  end
end
