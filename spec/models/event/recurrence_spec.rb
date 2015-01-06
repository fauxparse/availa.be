require 'rails_helper'

RSpec.describe Event::Recurrence, type: :model do
  subject(:recurrence) { FactoryGirl.build :recurrence }
  let(:event) { FactoryGirl.create :event }

  describe '#dates' do
    it 'only applies on specified weekdays' do
      recurrence.start_date = '2015-01-01'
      recurrence.end_date = '2015-01-31'
      recurrence.weekdays = [5]

      fridays_in_january_2015 = [
        Date.civil(2015, 1,  2),
        Date.civil(2015, 1,  9),
        Date.civil(2015, 1, 16),
        Date.civil(2015, 1, 23),
        Date.civil(2015, 1, 30)
      ]

      expect(recurrence.dates).to eq(fridays_in_january_2015)
    end
  end

  describe '#start_date=' do
    it 'sets the date in the correct timezone' do
      recurrence.time_zone = 'Wellington'
      recurrence.start_date = '2015-01-01'

      expect(recurrence.start_date.utc).to eq(Time.utc(2014, 12, 31, 11, 00))
    end

    it 'sets the weekday if the same as end_date' do
      recurrence.start_date = recurrence.end_date = '2015-01-01'

      expect(recurrence.weekdays).to eq [4]
    end
  end

  describe '#end_date=' do
    it 'sets the date in the correct timezone' do
      recurrence.time_zone = 'Wellington'
      recurrence.end_date = '2015-01-01'

      expected = Time.utc(2015, 1, 1, 10, 59).end_of_minute
      expect(recurrence.end_date.utc).to eq(expected)
    end

    it 'sets the weekday if the same as start_date' do
      recurrence.end_date = recurrence.start_date = '2015-01-01'

      expect(recurrence.weekdays).to eq [4]
    end
  end

  describe '#times' do
    it 'respects Daylight Saving' do
      recurrence.time_zone = 'Wellington'
      recurrence.start_date = '2015-04-04'
      recurrence.end_date = '2015-04-05' # Daylight Saving ends
      recurrence.start_time = 1.hours
      recurrence.end_time = 4.hours

      wlg = ActiveSupport::TimeZone['Wellington']
      expected = [
        wlg.local(2015, 4, 4, 1, 0)..wlg.local(2015, 4, 4, 4, 0),
        wlg.local(2015, 4, 5, 1, 0)..wlg.local(2015, 4, 5, 4, 0)
      ]

      actual = recurrence.times

      expect(actual).to eq(expected)

      # Here's the really weird part...
      expect(actual.first.range).to eq(3.hours)
      expect(actual.last.range).to eq(4.hours)
    end

    it 'accepts events straddling midnight' do
      recurrence.start_time = 23.hours
      recurrence.end_time = 1.hours

      first = recurrence.times.first
      expect(first.range).to eq(2.hours)
      expect(first.last.to_date).to eq(first.first.to_date + 1.day)
    end
  end

  describe '#time_zone=' do
    it 'preserves the start and end dates' do
      recurrence.start_date = '2015-01-01'
      recurrence.end_date = '2015-12-31'
      recurrence.start_time = 12.hours

      recurrence.time_zone = 'Hawaii'
      hawaii = ActiveSupport::TimeZone['Hawaii']

      expect(recurrence.times.first.first).to eq(hawaii.local(2015, 1, 1, 12))
    end
  end

  context 'when read back in' do
    before do
      event.recurrences = [recurrence]
      event.save
      event.reload
    end

    describe '#start_date' do
      it 'keeps the timezone' do
        recurrence = event.recurrences.first

        expected = ActiveSupport::TimeZone[recurrence.time_zone]
        expect(recurrence.start_date.time_zone).to eq(expected)
      end
    end
  end
end
