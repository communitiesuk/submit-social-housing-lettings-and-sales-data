FactoryBot.define do
  factory :organisation do
    name { "DLUHC" }
    providertype { "LA" }
    address_line1 { "2 Marsham Street" }
    address_line2 { "London" }
    postcode { "SW1P 4DF" }
    created_at { Time.zone.now }
    updated_at { Time.zone.now }
  end
end
