class Form::Sales::Questions::Buyer1Income < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "income1"
    @copy_key = "sales.income_benefits_and_savings.buyer_1_income.income1"
    @type = "numeric"
    @min = 0
    @max = 999_999
    @step = 1
    @width = 5
    @prefix = "£"
    @check_answers_card_number = 1
    @question_number = get_question_number_from_hash(QUESTION_NUMBER_FROM_YEAR)
    @strip_commas = true
  end

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 67, 2024 => 69, 2025 => 66, 2026 => 74 }.freeze
end
