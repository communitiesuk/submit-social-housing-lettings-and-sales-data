class Form::Lettings::Pages::AddressFallback < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "address"
    @copy_key = "lettings.property_information.address"
    @depends_on = [
      { "is_supported_housing?" => false, "uprn_known" => nil, "uprn_selection" => "uprn_not_listed" },
      { "is_supported_housing?" => false, "uprn_known" => 0, "uprn_selection" => "uprn_not_listed" },
      { "is_supported_housing?" => false, "uprn_confirmed" => 0, "uprn_selection" => "uprn_not_listed" },
      { "is_supported_housing?" => false, "uprn_known" => nil, "address_options_present?" => false },
      { "is_supported_housing?" => false, "uprn_known" => 0, "address_options_present?" => false },
      { "is_supported_housing?" => false, "uprn_confirmed" => 0, "address_options_present?" => false },
    ]
    @question_number = QUESTION_NUMBER_FROM_YEAR[form.start_date.year] || QUESTION_NUMBER_FROM_YEAR[QUESTION_NUMBER_FROM_YEAR.keys.max]
  end

  def questions
    @questions ||= [
      Form::Lettings::Questions::AddressLine1.new(nil, nil, self),
      Form::Lettings::Questions::AddressLine2.new(nil, nil, self),
      Form::Lettings::Questions::TownOrCity.new(nil, nil, self),
      Form::Lettings::Questions::County.new(nil, nil, self),
      Form::Lettings::Questions::PostcodeForFullAddress.new(nil, nil, self),
    ]
  end

  QUESTION_NUMBER_FROM_YEAR = { 2024 => 13, 2025 => 13 }.freeze
end
