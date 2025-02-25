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
    @question_number = question_number_from_year[form.start_date.year] || question_number_from_year[question_number_from_year.keys.max]
    @top_guidance_partial = "financial_calculations_shared_ownership"
  end

  def question_number_from_year
    { 2023 => 89, 2024 => 90, 2025 => subsection.id == "shared_ownership_staircasing_transaction" ? 98 : 81 }
  end
end
