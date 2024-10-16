class Form::Sales::Questions::Buyer1Income < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "income1"
    @type = "numeric"
    @min = 0
    @max = 999_999
    @step = 1
    @width = 5
    @prefix = "£"
    @check_answers_card_number = 1
    @question_number = QUESTION_NUMBER_FROM_YEAR[form.start_date.year] || QUESTION_NUMBER_FROM_YEAR[QUESTION_NUMBER_FROM_YEAR.keys.max]
  end

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 67, 2024 => 69 }.freeze
end
