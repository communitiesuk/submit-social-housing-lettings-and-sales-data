class Form::Sales::Pages::Address < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "address"
    @header = "Q#{QUESTION_NUMBER_FROM_YEAR[form.start_date.year] || QUESTION_NUMBER_FROM_YEAR[QUESTION_NUMBER_FROM_YEAR.keys.max]} - What is the property's address?"
    @depends_on = [
      { "uprn_known" => nil },
      { "uprn_known" => 0 },
      { "uprn_confirmed" => 0 },
    ]
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

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 15, 2024 => 16 }.freeze
end
