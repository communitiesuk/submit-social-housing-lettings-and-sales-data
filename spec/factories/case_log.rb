FactoryBot.define do
  factory :case_log do
    sequence(:id) { |i| i }
    trait :in_progress do
      status { 0 }
      tenant_code { "TH356" }
      postcode { "SW2 6HI" }
    end
    trait :submitted do
      status { 1 }
      tenant_code { "BZ737" }
      postcode { "NW1 7TY" }
    end
    trait :near_check_answers_household_characteristics do
      status { 0 }
      tenant_code { "AB123" }
      postcode { "LE11 2DW" }
      tenant_age { 25 }
      tenant_gender { "Male" }
      tenant_ethnic_group { "White: English/Scottish/Welsh/Northern Irish/British" }
      tenant_nationality { "UK national resident in UK" }
      tenant_economic_status { "Part-time - Less than 30 hours" }
    end
    created_at { Time.zone.now }
    updated_at { Time.zone.now }
  end
end
