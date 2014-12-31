FactoryGirl.define do
  factory :recurrence, class: Event::Recurrence do
    time_zone Time.zone.name
    start_date "2015-01-01"
    end_date "2015-12-31"
    start_time 12.hours
    end_time 13.hours
  end

end
