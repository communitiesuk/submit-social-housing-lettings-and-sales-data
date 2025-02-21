class Form::Lettings::Pages::AddressFallback < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "address"
    @copy_key = "lettings.property_information.address"
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

  QUESTION_NUMBER_FROM_YEAR = { 2024 => 13, 2025 => 17 }.freeze

  def routed_to?(log, _)
    return false unless super
    return false if log.is_supported_housing?
    return false if log.uprn_known != 0 && !log.uprn_known.nil? && log.uprn_confirmed != 0
    return false if log.uprn_selection != "uprn_not_listed" && log.address_options_present?

    true
  end
end
