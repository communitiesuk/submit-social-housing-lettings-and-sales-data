class Form::Sales::Questions::DiscountedOwnershipType < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "type"
    @copy_key = "sales.setup.type.discounted_ownership"
    @type = "radio"
    @top_guidance_partial = guidance_partial
    @answer_options = ANSWER_OPTIONS
    @question_number = QUESTION_NUMBER_FROM_YEAR[form.start_date.year] || QUESTION_NUMBER_FROM_YEAR[QUESTION_NUMBER_FROM_YEAR.keys.max]
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

  def guidance_partial
    "discounted_ownership_type_definitions" if form.start_date.year >= 2023
  end

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 5, 2024 => 7 }.freeze
end
