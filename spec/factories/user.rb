FactoryBot.define do
  factory :user do
    sequence(:email) { |i| "test#{i}@example.com" }
    name { "Danny Rojas" }
    password { "pAssword1" }
    organisation
    role { "Data Provider" }
    created_at { Time.zone.now }
    updated_at { Time.zone.now }
  end
end
