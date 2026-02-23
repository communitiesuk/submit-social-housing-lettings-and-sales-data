class Form::Lettings::Questions::Offered < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "offered"
    @type = "numeric"
    @width = 2
    @check_answers_card_number = 0
    @max = 150
    @min = 0
    @step = 1
    @question_number = get_question_number_from_hash(QUESTION_NUMBER_FROM_YEAR)
  end

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 18, 2024 => 18, 2025 => 18, 2026 => 18 }.freeze
end
