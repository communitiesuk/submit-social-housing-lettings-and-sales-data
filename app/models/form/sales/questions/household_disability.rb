class Form::Sales::Questions::HouseholdDisability < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "disabled"
    @type = "radio"
    @answer_options = ANSWER_OPTIONS
    @question_number = get_question_number_from_hash(QUESTION_NUMBER_FROM_YEAR)
  end

  ANSWER_OPTIONS = {
    "1" => { "value" => "Yes" },
    "2" => { "value" => "No" },
    "divider" => { "value" => true },
    "3" => { "value" => "Don’t know" },
  }.freeze

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 65, 2024 => 67, 2025 => 64, 2026 => 72 }.freeze
end
