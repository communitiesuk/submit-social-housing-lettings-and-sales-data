class FeatureToggle
  # Disable check on preview apps to allow for testing of future forms
  def self.saledate_collection_window_validation_enabled?
    true
  end

  def self.startdate_two_week_validation_enabled?
    Rails.env.production? || Rails.env.test? || Rails.env.staging?
  end

  def self.saledate_two_week_validation_enabled?
    Rails.env.production? || Rails.env.test? || Rails.env.staging? || Rails.env.review?
  end

  def self.bulk_upload_duplicate_log_check_enabled?
    !Rails.env.staging?
  end

  def self.upload_enabled?
    !Rails.env.development?
  end

  def self.force_crossover?
    false
  end

  def self.merge_organisations_enabled?
    !Rails.env.production?
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

  def self.sales_managing_organisation_enabled?
    true
  end
end
