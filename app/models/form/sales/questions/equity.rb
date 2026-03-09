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
    @question_number = get_question_number_from_hash(QUESTION_NUMBER_FROM_YEAR_AND_SECTION, value_key: subsection.id)
    @top_guidance_partial = "financial_calculations_shared_ownership"
  end

  QUESTION_NUMBER_FROM_YEAR_AND_SECTION = {
    2023 => 89,
    2024 => 90,
    2025 => { "shared_ownership_initial_purchase" => 81, "shared_ownership_staircasing_transaction" => 98 },
    2026 => { "shared_ownership_initial_purchase" => 81, "shared_ownership_staircasing_transaction" => 98 },
  }.freeze
end
