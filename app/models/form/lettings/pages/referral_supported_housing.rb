class Form::Lettings::Pages::ReferralSupportedHousing < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "referral_supported_housing"
    @copy_key = "lettings.household_situation.referral.supported_housing.la"
    @depends_on = [{ "owning_organisation_provider_type" => "LA", "needstype" => 2, "renewal" => 0 }]
  end

  def questions
    @questions ||= [Form::Lettings::Questions::ReferralSupportedHousing.new(nil, nil, self)]
  end
end
