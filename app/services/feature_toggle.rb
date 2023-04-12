class FeatureToggle
  # Disable check on preview apps to allow for testing of future forms
  def self.saledate_collection_window_validation_enabled?
    Rails.env.production? || Rails.env.test? || Rails.env.staging?
  end

  def self.startdate_two_week_validation_enabled?
    Rails.env.production? || Rails.env.test? || Rails.env.staging?
  end

  def self.saledate_two_week_validation_enabled?
    Rails.env.production? || Rails.env.test? || Rails.env.staging? || Rails.env.review?
  end

  def self.sales_log_enabled?
    true
  end

  def self.managing_owning_enabled?
    true
  end

  def self.scheme_toggle_enabled?
    true
  end

  def self.location_toggle_enabled?
    true
  end

  def self.managing_for_other_user_enabled?
    true
  end

  def self.bulk_upload_lettings_logs?
    true
  end

  def self.bulk_upload_sales_logs?
    !Rails.env.production?
  end

  def self.bulk_upload_duplicate_log_check_enabled?
    !Rails.env.staging?
  end

  def self.upload_enabled?
    !Rails.env.development?
  end

  def self.force_crossover?
    return false if Rails.env.test?

    !Rails.env.production?
  end

  def self.collection_2023_2024_year_enabled?
    true
  end

  def self.merge_organisations_enabled?
    !Rails.env.production?
  end
end
