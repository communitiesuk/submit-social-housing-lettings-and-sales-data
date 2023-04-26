require "securerandom"

FactoryBot.define do
  factory :bulk_upload_error do
    bulk_upload
    row { rand(9_999) }
    col { ("A".."Z").to_a.sample }
    cell { "#{col}#{row}" }
    tenant_code { SecureRandom.hex(4) }
    property_ref { SecureRandom.hex(4) }
    purchaser_code { SecureRandom.hex(4) }
    field { "field_#{rand(1..134)}" }
    error { "some error" }
  end
end
