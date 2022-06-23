class FeatureToggle
  def self.supported_housing_schemes_enabled?
    return true unless Rails.env.production?

    false
  end

  def self.startdate_two_week_validation_enabled?
    true
  end
end
