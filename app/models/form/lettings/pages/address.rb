class Form::Lettings::Pages::Address < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "address"
    @header = "Q#{QUESTION_NUMBER_FROM_YEAR[form.start_date.year] || QUESTION_NUMBER_FROM_YEAR[QUESTION_NUMBER_FROM_YEAR.keys.max]} - What is the property's address?"
    @depends_on = [
      { "is_supported_housing?" => false, "uprn_known" => nil },
      { "is_supported_housing?" => false, "uprn_known" => 0 },
      { "is_supported_housing?" => false, "uprn_confirmed" => 0 },
    ]
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

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 12, 2024 => 13 }.freeze
end
