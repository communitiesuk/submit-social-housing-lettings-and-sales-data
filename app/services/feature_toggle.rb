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

  def self.duplicate_summary_enabled?
    true
  end

  def self.service_unavailable?
    false
  end

  def self.service_moved?
    false
  end

  def self.delete_scheme_enabled?
    true
  end

  def self.delete_location_enabled?
    true
  end

  def self.delete_user_enabled?
    true
  end

  def self.local_storage?
    Rails.env.development?
  end

  def self.allow_future_resource_updates?
    !Rails.env.production? && !Rails.env.test?
  end

  def self.managing_resources_enabled?
    !Rails.env.production?
  end

  def self.create_test_logs_enabled?
    Rails.env.development?
  end
end
