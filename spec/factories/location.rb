FactoryBot.define do
  factory :location do
    location_code { Faker::Name.initials(number: 10) }
    postcode { Faker::Address.postcode.delete(" ") }
    name { Faker::Address.street_name }
    type_of_unit { Faker::Lorem.word }
    type_of_building { Faker::Lorem.word }
    wheelchair_adaptation { 0 }
    county { Faker::Address.state }
    scheme
  end
end
