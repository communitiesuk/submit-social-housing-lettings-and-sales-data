FactoryBot.define do
  factory :data_protection_confirmation do
    organisation { association :organisation, data_protection_confirmation: instance }
    data_protection_officer { association :user, :data_protection_officer, organisation: (instance.organisation || organisation) }

    organisation_name { organisation.name }
    organisation_address { organisation.address_row }
    organisation_phone_number { organisation.phone }
    data_protection_officer_name { data_protection_officer.name }
    data_protection_officer_email { data_protection_officer.email }

    confirmed { true }
    old_org_id { "7c5bd5fb549c09a2c55d7cb90d7ba84927e64618" }
    old_id { "7c5bd5fb549c09a2c55d7cb90d7ba84927e64618" }

    created_at { Time.zone.now }
    updated_at { Time.zone.now }
    signed_at { Time.zone.now }
  end
end
