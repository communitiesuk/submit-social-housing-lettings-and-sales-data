class Form::Lettings::Pages::ReferralSupportedHousing < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "referral_supported_housing"
    @header = ""
    @depends_on = [{ "managing_organisation_provider_type" => "LA", "needstype" => 2, "renewal" => 0 }]
    @description = ""
  end

  def questions
    @questions ||= [Form::Lettings::Questions::ReferralSupportedHousing.new(nil, nil, self)]
  end
end
