class Form::Lettings::Questions::SchargeBiWeekly < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "scharge"
    @copy_key = "lettings.income_and_benefits.rent_and_charges.scharge"
    @type = "numeric"
    @width = 5
    @check_answers_card_number = 0
    @min = 0
    @step = 0.01
    @fields_to_add = %w[brent scharge pscharge supcharg]
    @result_field = "tcharge"
    @prefix = "£"
    @suffix = " every 2 weeks"
    @question_number = QUESTION_NUMBER_FROM_YEAR[form.start_date.year] || QUESTION_NUMBER_FROM_YEAR[QUESTION_NUMBER_FROM_YEAR.keys.max]
  end

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 96, 2024 => 95 }.freeze
end
