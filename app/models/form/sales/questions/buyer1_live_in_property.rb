class Form::Sales::Questions::Buyer1LiveInProperty < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "buy1livein"
    @type = "radio"
    @answer_options = ANSWER_OPTIONS
    @check_answers_card_number = 1
    @question_number = get_question_number_from_hash(QUESTION_NUMBER_FROM_YEAR)
  end

  ANSWER_OPTIONS = {
    "1" => { "value" => "Yes" },
    "2" => { "value" => "No" },
  }.freeze

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 26, 2024 => 28, 2025 => 26, 2026 => 28 }.freeze
end
