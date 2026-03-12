class Form::Sales::Questions::Value < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "value"
    @copy_key = form.start_year_2025_or_later? ? "sales.sale_information.value.#{page.id}" : "sales.sale_information.value"
    @type = "numeric"
    @min = form.start_year_2026_or_later? ? 15_000 : 0
    @step = 1
    @width = 5
    @prefix = "£"
    @question_number = question_number_from_year[form.start_date.year] || question_number_from_year[question_number_from_year.keys.max]
    @top_guidance_partial = "financial_calculations_shared_ownership"
    @strip_commas = true
  end

  def question_number_from_year
    { 2023 => 88, 2024 => 89, 2025 => subsection.id == "shared_ownership_staircasing_transaction" ? 97 : 80 }
  end
end
