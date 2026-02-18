class FeatureToggle
  def self.allow_future_form_use?
    Rails.env.development? || Rails.env.review? || Rails.env.staging?
  end

  def self.bulk_upload_duplicate_log_check_enabled?
    !Rails.env.staging?
  end

  def self.upload_enabled?
    !Rails.env.development?
  end

  def self.service_unavailable?
    false
  end

  def self.service_moved?
    false
  end

  def self.local_storage?
    Rails.env.development?
  end

  def self.allow_future_resource_updates?
    !Rails.env.production? && !Rails.env.test?
  end

  def self.create_test_logs_enabled?
    Rails.env.development? || Rails.env.review? || Rails.env.staging?
  end

  def self.sales_export_enabled?
    Time.zone.now >= Time.zone.local(2025, 4, 1) || (Rails.env.review? || Rails.env.staging?)
  end
end
