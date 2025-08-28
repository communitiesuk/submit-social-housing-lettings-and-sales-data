class Form::Sales::Questions::MonthlyRent < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "mrent"
    @type = "numeric"
    @min = 0
    @step = 0.01
    @width = 5
    @prefix = "£"
    @question_number = QUESTION_NUMBER_FROM_YEAR[form.start_date.year] || QUESTION_NUMBER_FROM_YEAR[QUESTION_NUMBER_FROM_YEAR.keys.max]
    @strip_commas = true
  end

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 97, 2024 => 98, 2025 => 87 }.freeze
end
