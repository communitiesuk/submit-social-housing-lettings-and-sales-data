class FeatureToggle
  def self.startdate_two_week_validation_enabled?
    true
  end

  def self.sales_log_enabled?
    !Rails.env.production?
  end

  def self.managing_owning_enabled?
    !Rails.env.production?
  end

  def self.scheme_toggle_enabled?
    !Rails.env.production?
  end

  def self.location_toggle_enabled?
    !Rails.env.production?
  end
end
