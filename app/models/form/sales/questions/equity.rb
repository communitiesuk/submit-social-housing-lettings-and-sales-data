class Form::Sales::Questions::Equity < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "equity"
    @copy_key = form.start_year_2025_or_later? ? "sales.sale_information.equity.#{page.id}" : "sales.sale_information.equity"
    @type = "numeric"
    @min = 0
    @max = 100
    @step = 0.1
    @width = 5
    @suffix = "%"
    @question_number = QUESTION_NUMBER_FROM_YEAR[form.start_date.year] || QUESTION_NUMBER_FROM_YEAR[QUESTION_NUMBER_FROM_YEAR.keys.max]
    @top_guidance_partial = "financial_calculations_shared_ownership"
  end

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 89, 2024 => 90 }.freeze
end
