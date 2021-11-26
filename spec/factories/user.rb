FactoryBot.define do
  factory :user do
    sequence(:email) { |i| "test#{i}@example.com" }
    password { "pAssword1" }
    organisation
    created_at { Time.zone.now }
    updated_at { Time.zone.now }
  end
end
