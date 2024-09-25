require "securerandom"

FactoryBot.define do
  factory :bulk_upload do
    user
    log_type { BulkUpload.log_types.values.sample }
    year { Time.zone.now.month >= 4 ? Time.zone.now.year : Time.zone.now.year - 1 }
    identifier { SecureRandom.uuid }
    sequence(:filename) { |n| "bulk-upload-#{n}.csv" }
    needstype { 1 }
    rent_type_fix_status { BulkUpload.rent_type_fix_statuses.values.sample }
    organisation_id { user.organisation_id }

    trait(:sales) do
      log_type { BulkUpload.log_types[:sales] }
    end

    trait(:lettings) do
      log_type { BulkUpload.log_types[:lettings] }
    end
  end
end
