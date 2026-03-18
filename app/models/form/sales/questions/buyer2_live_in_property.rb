class Form::Sales::Questions::Buyer2LiveInProperty < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "buy2livein"
    @type = "radio"
    @answer_options = ANSWER_OPTIONS
    @check_answers_card_number = 2
    @question_number = get_question_number_from_hash(QUESTION_NUMBER_FROM_YEAR)
  end

  ANSWER_OPTIONS = {
    "1" => { "value" => "Yes" },
    "2" => { "value" => "No" },
  }.freeze

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 34, 2024 => 36, 2025 => 34, 2026 => 37 }.freeze
end
