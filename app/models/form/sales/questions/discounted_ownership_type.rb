class Form::Sales::Questions::DiscountedOwnershipType < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "type"
    @copy_key = "sales.setup.type.discounted_ownership"
    @type = "radio"
    @top_guidance_partial = guidance_partial
    @answer_options = form.start_year_2026_or_later? ? ANSWER_OPTIONS_2026_OR_LATER : ANSWER_OPTIONS
    @question_number = get_question_number_from_hash(QUESTION_NUMBER_FROM_YEAR)
  end

  ANSWER_OPTIONS = {
    "8" => { "value" => "Right to Acquire (RTA)" },
    "14" => { "value" => "Preserved Right to Buy (PRTB)" },
    "27" => { "value" => "Voluntary Right to Buy (VRTB)" },
    "9" => { "value" => "Right to Buy (RTB)" },
    "29" => { "value" => "Rent to Buy - Full Ownership" },
    "21" => { "value" => "Social HomeBuy for outright purchase" },
    "22" => { "value" => "Any other equity loan scheme" },
  }.freeze

  ANSWER_OPTIONS_2026_OR_LATER = {
    "8" => { "value" => "Right to Acquire (RTA)" },
    "14" => { "value" => "Preserved Right to Buy (PRTB)" },
    "9" => { "value" => "Right to Buy (RTB)" },
    "29" => { "value" => "Rent to Buy - Full Ownership" },
    "21" => { "value" => "Social HomeBuy for outright purchase" },
    "22" => { "value" => "Any other equity loan scheme" },
  }.freeze

  def guidance_partial
    "discounted_ownership_type_definitions" if form.start_date.year >= 2023
  end

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 5, 2024 => 7, 2025 => 8, 2026 => 8 }.freeze
end
