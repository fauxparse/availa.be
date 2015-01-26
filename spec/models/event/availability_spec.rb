require 'rails_helper'

RSpec.describe Event::Availability, type: :model do
  let(:group) { FactoryGirl.create :group }
  let(:event) do
    FactoryGirl.create :event,
      group: group,
      recurrences: [recurrence]
  end
  let(:recurrence) do
    FactoryGirl.build :recurrence,
      start_date: '2015-01-01',
      end_date: '2015-01-31',
      weekdays: [6]
  end

  [:dumbledore, :harry, :hermione, :ron].each do |user|
    let(user) { FactoryGirl.create user }
  end

  it { is_expected.to validate_uniqueness_of(:user_id) }

  context 'with no availability given' do
    it 'does not exist' do
      expect(harry).not_to be_available_for(event)
    end
  end

  # context 'with availability given without times' do
  #   before do
  #     event.availability.create user: harry
  #   end
  #
  #   it 'exists' do
  #     expect(event.availability_for(harry)).to exist
  #   end
  #
  #   it 'is not available' do
  #     availability = event.availability_for(harry)
  #     expect(availability).not_to be_available_for(event.times.first.first)
  #   end
  # end

  # context 'with availability given with times' do
  #   before do
  #     event.availability.create user: harry, times: [event.times.first.first]
  #   end
  #
  #   it 'exists' do
  #     expect(event.availability_for(harry)).to exist
  #   end
  #
  #   it 'is available for the dates given' do
  #     availability = event.availability_for(harry)
  #     expect(availability).to be_available_for(event.times.first.first)
  #   end
  #
  #   it 'is not available for other dates' do
  #     availability = event.availability_for(harry)
  #     expect(availability).not_to be_available_for(event.times.second.first)
  #   end
  # end

  # context 'with negative availability given' do
  #   before do
  #     event.availability.create user: harry, available: false
  #   end
  #
  #   it 'exists' do
  #     expect(event.availability_for(harry)).to exist
  #   end
  #
  #   it 'is not available' do
  #     availability = event.availability_for(harry)
  #     expect(availability).not_to be_available_for(event.times.first.first)
  #   end
  # end
end
