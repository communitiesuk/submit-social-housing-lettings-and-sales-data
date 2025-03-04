class Form::Sales::Pages::AddressFallback < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "address"
    @copy_key = "sales.property_information.address"
    @depends_on = [
      { "uprn_known" => nil, "uprn_selection" => "uprn_not_listed" },
      { "uprn_known" => 0, "uprn_selection" => "uprn_not_listed" },
      { "uprn_confirmed" => 0, "uprn_selection" => "uprn_not_listed" },
      { "uprn_known" => nil, "address_options_present?" => false },
      { "uprn_known" => 0, "address_options_present?" => false },
      { "uprn_confirmed" => 0, "address_options_present?" => false },
    ]
    @question_number = QUESTION_NUMBER_FROM_YEAR[form.start_date.year] || QUESTION_NUMBER_FROM_YEAR[QUESTION_NUMBER_FROM_YEAR.keys.max]
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::AddressLine1.new(nil, nil, self),
      Form::Sales::Questions::AddressLine2.new(nil, nil, self),
      Form::Sales::Questions::TownOrCity.new(nil, nil, self),
      Form::Sales::Questions::County.new(nil, nil, self),
      Form::Sales::Questions::PostcodeForFullAddress.new(nil, nil, self),
    ]
  end

  QUESTION_NUMBER_FROM_YEAR = { 2024 => 16, 2025 => 16 }.freeze
end
