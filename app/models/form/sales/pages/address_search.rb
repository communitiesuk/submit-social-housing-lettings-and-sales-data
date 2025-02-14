class Form::Sales::Pages::AddressSearch < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "address_search"
    @depends_on = [{ "address_search_input" => true }]
    @question_number = QUESTION_NUMBER_FROM_YEAR[form.start_date.year] || QUESTION_NUMBER_FROM_YEAR[QUESTION_NUMBER_FROM_YEAR.keys.max]
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::AddressSearch.new(nil, nil, self),
    ]
  end

  def skip_href(log = nil)
    return unless log

    "/#{log.log_type.dasherize}s/#{log.id}/property-number-of-bedrooms"
  end

  QUESTION_NUMBER_FROM_YEAR = { 2024 => 15, 2025 => 15 }.freeze
end
