class Form::Lettings::Questions::Joint < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "joint"
    @type = "radio"
    @check_answers_card_number = 0
    @answer_options = ANSWER_OPTIONS
    @question_number = get_question_number_from_hash(QUESTION_NUMBER_FROM_YEAR)
  end

  ANSWER_OPTIONS = {
    "1" => { "value" => "Yes" },
    "2" => { "value" => "No" },
    "divider" => { "value" => true },
    "3" => { "value" => "Don’t know" },
  }.freeze

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 25, 2024 => 25, 2025 => 26, 2026 => 25 }.freeze
end
