class FeatureToggle
  def self.supported_housing_schemes_enabled?
    return true unless Rails.env.production?

    false
  end
end
