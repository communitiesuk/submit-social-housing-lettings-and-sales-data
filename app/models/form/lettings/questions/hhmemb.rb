class Form::Lettings::Questions::Hhmemb < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "hhmemb"
    @type = "numeric"
    @width = 2
    @check_answers_card_number = 0
    @max = 8
    @min = 1
    @step = 1
    @question_number = get_question_number_from_hash(QUESTION_NUMBER_FROM_YEAR)
  end

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 31, 2024 => 30, 2025 => 30, 2026 => 29 }.freeze
end
