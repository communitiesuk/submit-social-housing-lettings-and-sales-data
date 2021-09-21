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
    created_at { Time.now }
    updated_at { Time.now }
  end
end
