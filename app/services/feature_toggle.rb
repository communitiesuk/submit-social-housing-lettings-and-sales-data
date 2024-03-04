class FeatureToggle
  def self.allow_future_form_use?
    Rails.env.development? || Rails.env.staging?
  end

  def self.bulk_upload_duplicate_log_check_enabled?
    !Rails.env.staging?
  end

  def self.upload_enabled?
    !Rails.env.development?
  end

  def self.deduplication_flow_enabled?
    true
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
end
