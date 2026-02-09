class Form::Lettings::Questions::PschargeMonthly < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "pscharge"
    @copy_key = "lettings.income_and_benefits.rent_and_charges.pscharge"
    @type = "numeric"
    @width = 5
    @check_answers_card_number = 0
    @min = 0
    @step = 0.01
    @fields_to_add = %w[brent scharge pscharge supcharg]
    @result_field = "tcharge"
    @prefix = "£"
    @suffix = " every month"
    @question_number = QUESTION_NUMBER_FROM_YEAR[form.start_date.year]
    @strip_commas = true
  end

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 97, 2024 => 96, 2025 => 94, 2026 => 93 }.freeze
end
