FactoryBot.define do
  factory :location do
    postcode { Faker::Address.postcode.delete(" ") }
    name { Faker::Address.street_name }
    type_of_unit { [1, 2, 3, 4, 6, 7].sample }
    units { [1, 2, 3, 4, 6, 7].sample }
    mobility_type { %w[A M N W X].sample }
    location_code { "E09000033" }
    location_admin_district { "Westminster" }
    startdate { Time.zone.local(2022, 4, 1) }
    confirmed { true }
    scheme

    trait :export do
      postcode { "SW1A 2AA" }
      name { "Downing Street" }
      type_of_unit { 7 }
      units { 20 }
      mobility_type { "A" }
      scheme { FactoryBot.create(:scheme, :export) }
      old_visible_id { "111" }
    end

    trait :with_old_visible_id do
      old_visible_id { rand(9_999_999).to_s }
    end
  end
end
