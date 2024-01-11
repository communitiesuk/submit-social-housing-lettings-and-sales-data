FactoryBot.define do
  factory :duplicate_log_reference do
    log_id { 1 }
    log_type { "SalesLog" }
    duplicate_log_reference_id { nil }
    created_at { Time.zone.today }
    updated_at { Time.zone.today }
  end
end
