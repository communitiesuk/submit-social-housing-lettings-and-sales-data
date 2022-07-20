FactoryBot.define do
  factory :location do
    postcode { Faker::Address.postcode.delete(" ") }
    name { Faker::Address.street_name }
    type_of_unit { [1, 2, 3, 4, 6, 7].sample }
    units { [1, 2, 3, 4, 6, 7].sample }
    type_of_building { "Purpose built" }
    mobility_type { %w[A M N W X].sample }
    wheelchair_adaptation { 2 }
    scheme
    trait :export do
      postcode { "SW1A 2AA" }
      name { "Downing Street" }
      type_of_unit { 7 }
      units { 20 }
      mobility_type { "A" }
      scheme { FactoryBot.create(:scheme, :export) }
      old_visible_id { 111 }
    end
  end
end
