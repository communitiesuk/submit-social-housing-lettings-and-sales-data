FactoryBot.define do
  factory :location do
    location_code { Faker::Name.initials(number: 10) }
    postcode { Faker::Address.postcode.delete(" ") }
    name { Faker::Address.street_name }
    address_line1 { Faker::Address.street_name }
    address_line2 { Faker::Address.city }
    type_of_unit { Faker::Number.within(range: 1..6) }
    type_of_building { Faker::Lorem.word }
    wheelchair_adaptation { 0 }
    county { Faker::Address.state }
    scheme
  end
end
