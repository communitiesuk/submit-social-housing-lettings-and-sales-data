class Form::Sales::Questions::ArmedForces < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "hhregres"
    @type = "radio"
    @answer_options = ANSWER_OPTIONS
    @question_number = get_question_number_from_hash(QUESTION_NUMBER_FROM_YEAR)
  end

  ANSWER_OPTIONS = {
    "1" => { "value" => "Yes" },
    "7" => { "value" => "No" },
    "3" => { "value" => "Buyer prefers not to say" },
    "divider" => { "value" => true },
    "8" => { "value" => "Don’t know" },
  }.freeze

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 62, 2024 => 64, 2025 => 61, 2026 => 69 }.freeze
end
