class Form::Sales::Questions::Prevshared < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "prevshared"
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

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 74, 2024 => 76, 2025 => 73, 2026 => 81 }.freeze
end
