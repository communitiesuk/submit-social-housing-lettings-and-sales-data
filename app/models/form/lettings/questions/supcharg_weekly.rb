class Form::Lettings::Questions::SupchargWeekly < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "supcharg"
    @copy_key = "lettings.income_and_benefits.rent_and_charges.supcharg"
    @type = "numeric"
    @width = 5
    @check_answers_card_number = 0
    @min = 0
    @step = 0.01
    @fields_to_add = %w[brent scharge pscharge supcharg]
    @result_field = "tcharge"
    @prefix = "£"
    @suffix = " every week"
    @question_number = QUESTION_NUMBER_FROM_YEAR[form.start_date.year]
    @strip_commas = true
  end

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 98, 2024 => 97, 2025 => 95, 2026 => 102 }.freeze
end
