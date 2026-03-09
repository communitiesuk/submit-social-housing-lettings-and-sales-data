class Form::Sales::Questions::MortgageAmount < ::Form::Question
  def initialize(id, hsh, page, ownershipsch:)
    super(id, hsh, page)
    @id = "mortgage"
    @type = "numeric"
    @min = 1
    @step = 1
    @width = 5
    @prefix = "£"
    @ownershipsch = ownershipsch
    @question_number = get_question_number_from_hash(QUESTION_NUMBER_FROM_YEAR_AND_SECTION, value_key: form.start_year_2026_or_later? ? subsection.id : ownershipsch)
    @top_guidance_partial = top_guidance_partial
    @strip_commas = true
  end

  QUESTION_NUMBER_FROM_YEAR_AND_SECTION = {
    2023 => { 1 => 91, 2 => 104, 3 => 112 },
    2024 => { 1 => 92, 2 => 105, 3 => 113 },
    2025 => { 1 => 83, 2 => 107 },
    2026 => { "shared_ownership_initial_purchase" => 83, "discounted_ownership_scheme" => 107 },
  }.freeze

  def derived?(log)
    log&.mortgage_not_used?
  end

  def top_guidance_partial
    return "financial_calculations_shared_ownership" if @ownershipsch == 1
    return "financial_calculations_discounted_ownership" if @ownershipsch == 2

    "financial_calculations_outright_sale" if @ownershipsch == 3
  end
end
