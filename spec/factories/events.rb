FactoryGirl.define do
  factory :event do
    name "Quidditch"
    recurrences [
      Event::Recurrence.new(
        start_date: "2015-01-01",
        end_date: "2015-12-31",
        start_time: 9.hours,
        end_time: 11.hours,
        weekdays: [6]
      )
    ]
  end

end
