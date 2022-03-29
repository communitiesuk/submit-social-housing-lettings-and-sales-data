FactoryBot.define do
  factory :user do
    sequence(:email) { |i| "test#{i}@example.com" }
    name { "Danny Rojas" }
    password { "pAssword1" }
    organisation
    role { "data_provider" }
    trait :data_coordinator do
      role { "data_coordinator" }
    end
    trait :data_protection_officer do
      is_dpo { true }
    end
    created_at { Time.zone.now }
    updated_at { Time.zone.now }
  end
end
