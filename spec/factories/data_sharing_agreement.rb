FactoryBot.define do
  factory :data_sharing_agreement do
    organisation { association :organisation, data_sharing_agreement: instance }

    signed_at { Time.zone.now }
    created_at { Time.zone.now }
    updated_at { Time.zone.now }

    dpo_name { data_protection_officer&.name || "DPO Name" }
    dpo_email { data_protection_officer&.email || "test@example.com" }
    organisation_address { organisation }
    organisation_phone_number { organisation }
    organisation_name { organisation }
  end
end
