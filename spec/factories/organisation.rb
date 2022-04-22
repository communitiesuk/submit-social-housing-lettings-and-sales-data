FactoryBot.define do
  factory :organisation do
    name { "DLUHC" }
    address_line1 { "2 Marsham Street" }
    address_line2 { "London" }
    provider_type { "LA" }
    postcode { "SW1P 4DF" }
    created_at { Time.zone.now }
    updated_at { Time.zone.now }
  end

  factory :organisation_la do
    organisation
    ons_code { "E07000041" }
    created_at { Time.zone.now }
    updated_at { Time.zone.now }
  end
end
