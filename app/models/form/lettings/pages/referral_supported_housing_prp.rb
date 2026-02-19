# removed in 2025
class Form::Lettings::Pages::ReferralSupportedHousingPrp < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "referral_supported_housing_prp"
    @copy_key = "lettings.household_situation.referral.supported_housing.prp"
    @depends_on = [{ "owning_organisation_provider_type" => "PRP", "needstype" => 2, "renewal" => 0 }]
  end

  def questions
    @questions ||= [Form::Lettings::Questions::ReferralSupportedHousingPrp.new(nil, nil, self)]
  end
end
