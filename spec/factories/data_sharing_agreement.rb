FactoryBot.define do
  factory :data_sharing_agreement do
    organisation { association :organisation, data_sharing_agreement: instance }
    data_protection_officer { association :user, :data_protection_officer, organisation: (instance.organisation || organisation) }

    signed_at { Time.zone.now }
    created_at { Time.zone.now }
    updated_at { Time.zone.now }

    dpo_name { data_protection_officer.name }
    dpo_email { data_protection_officer.email }
    organisation_address { organisation.address_string }
    organisation_phone_number { organisation.phone }
    organisation_name { organisation.name }
  end
end
