class Form::Lettings::Questions::BrentMonthly < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "brent"
    @copy_key = "lettings.income_and_benefits.rent_and_charges.brent"
    @type = "numeric"
    @width = 5
    @check_answers_card_number = 0
    @min = 0
    @step = 0.01
    @fields_to_add = %w[brent scharge pscharge supcharg]
    @result_field = "tcharge"
    @prefix = "£"
    @suffix = " every month"
    @question_number = get_question_number_from_hash(QUESTION_NUMBER_FROM_YEAR)
    @strip_commas = true
  end

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 95, 2024 => 94, 2025 => 92, 2026 => 100 }.freeze
end
