class FeatureToggle
  def self.startdate_two_week_validation_enabled?
    true
  end

  def self.sales_log_enabled?
    return true unless Rails.env.production?

    false
  end

  def self.managing_owning_enabled?
    return true unless Rails.env.production?

    false
  end

  def self.location_toggle_enabled?
    return true unless Rails.env.production?

    false
  end
end
