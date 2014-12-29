FactoryGirl.define do
  factory :user do
    name "Dumbledore"
    email "head@hogwarts.ac.uk"
    password "sherbetlemon"
    password_confirmation "sherbetlemon"

    factory :dumbledore

    factory :harry do
      name "Harry Potter"
      email "harry.potter@hogwarts.ac.uk"
    end

    factory :hermione do
      name "Hermione Granger"
      email "hermione.granger@hogwarts.ac.uk"
    end
  end

end
