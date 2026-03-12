class Form::Sales::Questions::Buyer2Income < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "income2"
    @copy_key = "sales.income_benefits_and_savings.buyer_2_income.income2"
    @type = "numeric"
    @min = 0
    @max = 999_999
    @step = 1
    @width = 5
    @prefix = "£"
    @check_answers_card_number = 2
    @question_number = get_question_number_from_hash(QUESTION_NUMBER_FROM_YEAR)
    @strip_commas = true
  end

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 69, 2024 => 71, 2025 => 68, 2026 => 76 }.freeze
end
