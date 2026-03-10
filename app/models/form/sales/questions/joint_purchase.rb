class Form::Sales::Questions::JointPurchase < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "jointpur"
    @type = "radio"
    @answer_options = ANSWER_OPTIONS
    @question_number = get_question_number_from_hash(QUESTION_NUMBER_FROM_YEAR)
  end

  ANSWER_OPTIONS = {
    "1" => { "value" => "Yes" },
    "2" => { "value" => "No" },
  }.freeze

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 9, 2024 => 11, 2025 => 9, 2026 => 9 }.freeze
end
