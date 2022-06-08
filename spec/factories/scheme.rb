FactoryBot.define do
  factory :scheme do
    code { Faker::Name.initials(number: 4) }
    service { Faker::Name.name_with_middle }
    organisation
    created_at { Time.zone.now }
  end
end
