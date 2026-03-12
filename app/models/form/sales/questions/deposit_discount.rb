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
    @question_number = get_question_number_from_hash(QUESTION_NUMBER_FROM_YEAR)
    @top_guidance_partial = "financial_calculations_shared_ownership"
    @strip_commas = true
  end

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 96, 2024 => 97, 2025 => 86, 2026 => 94 }.freeze
end
