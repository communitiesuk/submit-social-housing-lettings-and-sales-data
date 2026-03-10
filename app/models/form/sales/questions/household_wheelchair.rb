class Form::Sales::Questions::HouseholdWheelchair < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "wheel"
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

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 66, 2024 => 68, 2025 => 65, 2026 => 73 }.freeze
end
