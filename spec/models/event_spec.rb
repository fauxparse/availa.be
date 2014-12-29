require 'rails_helper'

RSpec.describe Event, :type => :model do
  subject(:event) { FactoryGirl.create :event }

  context "for Saturdays in 2015" do
    before do
      event.update recurrences: [{
        start_date: "2015-01-01",
        end_date: "2015-12-31",
        start_time: 9.hours,
        end_time: 11.hours,
        weekdays: [6]
      }]
    end

    describe "#times" do
      it "generates a list of times" do
        # http://www.convertunits.com/dates/howmany/Saturdays-in-2015
        expect(event.times.length).to eq(52)
      end
    end
  end
end
