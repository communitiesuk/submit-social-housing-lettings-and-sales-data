require "securerandom"

FactoryBot.define do
  factory :bulk_upload do
    user
    log_type { BulkUpload.log_types.values.sample }
    year { 2022 }
    identifier { SecureRandom.uuid }
  end
end
