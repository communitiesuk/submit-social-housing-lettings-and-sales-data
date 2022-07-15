FactoryBot.define do
  factory :location do
    postcode { Faker::Address.postcode.delete(" ") }
    name { Faker::Address.street_name }
    type_of_unit { [1, 2, 3, 4, 6, 7].sample }
    type_of_building { "Purpose built" }
    mobility_type { %w[A M N W X].sample }
    wheelchair_adaptation { 2 }
    scheme
  end
end
