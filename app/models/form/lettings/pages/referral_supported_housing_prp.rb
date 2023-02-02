class Form::Lettings::Pages::ReferralSupportedHousingPrp < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "referral_supported_housing_prp"
    @depends_on = [{ "managing_organisation_provider_type" => "PRP", "needstype" => 2, "renewal" => 0 }]
  end

  def questions
    @questions ||= [Form::Lettings::Questions::ReferralSupportedHousingPrp.new(nil, nil, self)]
  end
end
