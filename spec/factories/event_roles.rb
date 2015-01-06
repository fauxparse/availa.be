FactoryGirl.define do
  factory :role, class: 'Event::Role' do
    skill { FactoryGirl.build :skill }
  end
end
