class FeatureToggle
  def self.startdate_two_week_validation_enabled?
    true
  end

  def self.sales_log_enabled?
    return true unless Rails.env.production? 

    false
  end
end
