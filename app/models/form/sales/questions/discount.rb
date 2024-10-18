class Form::Sales::Questions::Discount < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "discount"
    @type = "numeric"
    @copy_key = "sales.sale_information.discount"
    @min = 0
    @max = form.start_year_after_2024? ? 70 : 100
    @step = 0.1
    @width = 5
    @suffix = "%"
    @question_number = QUESTION_NUMBER_FROM_YEAR[form.start_date.year] || QUESTION_NUMBER_FROM_YEAR[QUESTION_NUMBER_FROM_YEAR.keys.max]
    @top_guidance_partial = "financial_calculations_discounted_ownership"
  end

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 102, 2024 => 103 }.freeze
end
