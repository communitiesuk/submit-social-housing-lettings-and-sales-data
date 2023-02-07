class FeatureToggle
  def self.startdate_two_week_validation_enabled?
    Rails.env.production? || Rails.env.test?
  end

  def self.sales_log_enabled?
    !Rails.env.production?
  end

  def self.managing_owning_enabled?
    !Rails.env.production?
  end

  def self.scheme_toggle_enabled?
    true
  end

  def self.location_toggle_enabled?
    true
  end

  def self.managing_for_other_user_enabled?
    !Rails.env.production?
  end

  def self.bulk_upload_logs?
    !Rails.env.production?
  end

  def self.upload_enabled?
    !Rails.env.development?
  end

  def self.validate_valid_radio_options?
    !(Rails.env.production? || Rails.env.staging?)
  end
end
