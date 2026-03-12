class Form::Sales::Questions::Buyer2LivingIn < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "buy2living"
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

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 60, 2024 => 62, 2025 => 59, 2026 => 67 }.freeze
end
