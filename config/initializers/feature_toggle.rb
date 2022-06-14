class FeatureToggle
  def self.needs_question_enabled?
    !Rails.env.production?
  end

  def self.show_schemes_button?
    Rails.env.production?
  end
end
