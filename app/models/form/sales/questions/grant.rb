class Form::Sales::Questions::Grant < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "grant"
    @type = "numeric"
    @min = 0
    @max = 999_999
    @step = 1
    @width = 5
    @prefix = "£"
    @question_number = QUESTION_NUMBER_FROM_YEAR[form.start_date.year] || QUESTION_NUMBER_FROM_YEAR[QUESTION_NUMBER_FROM_YEAR.keys.max]
    @top_guidance_partial = "financial_calculations_discounted_ownership"
  end

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 101, 2024 => 102, 2025 => 104 }.freeze
end
