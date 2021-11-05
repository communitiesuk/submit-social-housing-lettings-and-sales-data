FactoryBot.define do
  factory :case_log do
    sequence(:id) { |i| i }
    trait :in_progress do
      status { 1 }
      tenant_code { "TH356" }
      property_postcode { "SW2 6HI" }
      previous_postcode { "P0 5ST" }
      age1 { "17" }
    end
    trait :completed do
      status { 2 }
      tenant_code { "BZ737" }
      property_postcode { "NW1 7TY" }
    end
    trait :soft_validations_triggered do
      status { 1 }
      person_1_economic_status { "Full-time - 30 hours or more" }
      net_income { 750 }
      net_income_frequency { "Weekly" }
    end
    created_at { Time.zone.now }
    updated_at { Time.zone.now }
  end
end
