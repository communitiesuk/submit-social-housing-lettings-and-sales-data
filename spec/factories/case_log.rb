FactoryBot.define do
  factory :case_log do
    sequence(:id) { |i| i }
    trait :in_progress do
      status { 1 }
      tenant_code { "TH356" }
      property_postcode { "SW2 6HI" }
      previous_postcode { "P0 5ST" }
      tenant_age { "12" }
    end
    trait :completed do
      status { 2 }
      tenant_code { "BZ737" }
      property_postcode { "NW1 7TY" }
    end
    created_at { Time.zone.now }
    updated_at { Time.zone.now }
  end
end
