class Form::Lettings::Questions::PschargeWeekly < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "pscharge"
    @copy_key = "lettings.income_and_benefits.rent.pscharge"
    @type = "numeric"
    @width = 5
    @check_answers_card_number = 0
    @min = 0
    @step = 0.01
    @fields_to_add = %w[brent scharge pscharge supcharg]
    @result_field = "tcharge"
    @prefix = "£"
    @suffix = " every week"
    @question_number = QUESTION_NUMBER_FROM_YEAR[form.start_date.year] || QUESTION_NUMBER_FROM_YEAR[QUESTION_NUMBER_FROM_YEAR.keys.max]
  end

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 97, 2024 => 96 }.freeze
end
