FactoryBot.define do
  factory :case_log do
    sequence(:id) { |i| i }
    trait :in_progress do
      status { 1 }
      tenant_code { "TH356" }
      property_postcode { "P0 5ST" }
      previous_postcode { "SW2 6HI" }
      age1 { "17" }
    end
    trait :completed do
      status { 2 }
      tenant_code { "BZ737" }
      property_postcode { "NW1 7TY" }
    end
    trait :soft_validations_triggered do
      status { 1 }
      ecstat1 { "Full-time - 30 hours or more" }
      earnings { 750 }
      incfreq { "Weekly" }
    end
    trait :conditional_section_complete do
      tenant_code { "TH356" }
      age1 { 34 }
      sex1 { "M" }
      ethnic { 2 }
      national { 4 }
      ecstat1 { 2 }
      other_hhmemb { 0 }
    end
    created_at { Time.zone.now }
    updated_at { Time.zone.now }
  end
end
