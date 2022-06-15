FactoryBot.define do
  factory :location do
    location_code { Faker::Name.initials(number: 10) }
    postcode { Faker::Address.postcode }
    scheme
  end
end
