class Form::Sales::Questions::DepositDiscount < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "cashdis"
    @type = "numeric"
    @min = 0
    @max = 999_999
    @step = 1
    @width = 5
    @prefix = "£"
    @question_number = QUESTION_NUMBER_FROM_YEAR[form.start_date.year] || QUESTION_NUMBER_FROM_YEAR[QUESTION_NUMBER_FROM_YEAR.keys.max]
    @top_guidance_partial = "financial_calculations_shared_ownership"
  end

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 96, 2024 => 97, 2025 => 86 }.freeze
end
