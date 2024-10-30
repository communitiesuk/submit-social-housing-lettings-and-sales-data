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
    @question_number = QUESTION_NUMBER_FROM_YEAR[form.start_date.year] || QUESTION_NUMBER_FROM_YEAR[QUESTION_NUMBER_FROM_YEAR.keys.max]
  end

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 31, 2024 => 30 }.freeze
end
