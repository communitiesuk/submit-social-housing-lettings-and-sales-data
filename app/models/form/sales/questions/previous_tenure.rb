class Form::Sales::Questions::PreviousTenure < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "socprevten"
    @type = "radio"
    @page = page
    @answer_options = ANSWER_OPTIONS
    @question_number = get_question_number_from_hash(QUESTION_NUMBER_FROM_YEAR)
  end

  ANSWER_OPTIONS = {
    "1" => { "value" => "Social Rent" },
    "2" => { "value" => "Affordable Rent" },
    "3" => { "value" => "London Affordable Rent" },
    "9" => { "value" => "Other" },
    "divider" => { "value" => true },
    "10" => { "value" => "Don’t know" },
  }.freeze

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 87, 2024 => 88, 2025 => 79, 2026 => 87 }.freeze
end
