class Form::Sales::Questions::Value < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "value"
    @copy_key = form.start_year_2025_or_later? ? "sales.sale_information.value.#{page.id}" : "sales.sale_information.value"
    @type = "numeric"
    @min = 0
    @step = 1
    @width = 5
    @prefix = "£"
    @question_number = QUESTION_NUMBER_FROM_YEAR[form.start_date.year] || QUESTION_NUMBER_FROM_YEAR[QUESTION_NUMBER_FROM_YEAR.keys.max]
    @top_guidance_partial = "financial_calculations_shared_ownership"
  end

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 88, 2024 => 89 }.freeze
end
