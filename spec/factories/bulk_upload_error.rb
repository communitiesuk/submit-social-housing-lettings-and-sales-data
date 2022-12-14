require "securerandom"

FactoryBot.define do
  factory :bulk_upload_error do
    bulk_upload
    row { rand(9_999) }
    cell { "#{('A'..'Z').to_a.sample}#{row}" }
    tenant_code { SecureRandom.hex(4) }
    property_ref { SecureRandom.hex(4) }
    field { "field_#{rand(134)}" }
    error { "some error" }
  end
end
