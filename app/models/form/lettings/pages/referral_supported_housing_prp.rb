class Form::Lettings::Pages::ReferralSupportedHousingPrp < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "referral_supported_housing_prp"
    @header = ""
    @depends_on = [{ "managing_organisation_provider_type" => "PRP", "needstype" => 2, "renewal" => 0 }]
    @description = ""
  end

  def questions
    @questions ||= [Form::Lettings::Questions::Referral.new(nil, nil, self)]
  end
end
