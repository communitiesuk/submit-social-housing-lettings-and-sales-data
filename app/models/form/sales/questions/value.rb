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
    @question_number = get_question_number_from_hash(QUESTION_NUMBER_FROM_YEAR_AND_SECTION, value_key: subsection.id)
    @top_guidance_partial = "financial_calculations_shared_ownership"
    @strip_commas = true
  end

  QUESTION_NUMBER_FROM_YEAR_AND_SECTION = {
    2023 => 88,
    2024 => 89,
    2025 => { "shared_ownership_initial_purchase" => 80, "shared_ownership_staircasing_transaction" => 97 },
    2026 => { "shared_ownership_initial_purchase" => 80, "shared_ownership_staircasing_transaction" => 97 },
  }.freeze
end
