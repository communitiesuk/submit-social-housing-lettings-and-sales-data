FactoryBot.define do
  factory :data_protection_confirmation do
    organisation { association :organisation, data_protection_confirmation: instance }
    data_protection_officer { association :user, :data_protection_officer, organisation: (instance.organisation || organisation) }

    confirmed { true }
    old_org_id { "7c5bd5fb549c09a2c55d7cb90d7ba84927e64618" }
    old_id { "7c5bd5fb549c09a2c55d7cb90d7ba84927e64618" }

    created_at { Time.zone.now }
    updated_at { Time.zone.now }
  end
end
