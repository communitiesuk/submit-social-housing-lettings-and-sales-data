class Form::Sales::Questions::DepositAmount < ::Form::Question
  def initialize(id, hsh, page, ownershipsch:, optional:)
    super(id, hsh, page)
    @id = "deposit"
    @type = "numeric"
    @min = 0
    @max = 999_999
    @step = 1
    @width = 5
    @prefix = "£"
    @ownershipsch = ownershipsch
    @question_number = get_question_number_from_hash(QUESTION_NUMBER_FROM_YEAR_AND_SECTION, value_key: form.start_year_2026_or_later? ? subsection.id : ownershipsch)
    @optional = optional
    @top_guidance_partial = top_guidance_partial
    @copy_key = copy_key
    @strip_commas = true
  end

  def derived?(log)
    log.outright_sale? && !log.mortgage_used?
  end

  QUESTION_NUMBER_FROM_YEAR_AND_SECTION = {
    2023 => { 1 => 95, 2 => 108, 3 => 116 },
    2024 => { 1 => 96, 2 => 109, 3 => 116 },
    2025 => { 1 => 85, 2 => 110 },
    2026 => { "shared_ownership_initial_purchase" => 93, "discounted_ownership_scheme" => 120 },
  }.freeze

  def top_guidance_partial
    return "financial_calculations_shared_ownership" if @ownershipsch == 1
    return "financial_calculations_discounted_ownership" if @ownershipsch == 2

    "financial_calculations_outright_sale" if @ownershipsch == 3
  end

  def copy_key
    return "sales.sale_information.deposit.shared_ownership" if @ownershipsch == 1
    return "sales.sale_information.deposit.discounted_ownership" if @ownershipsch == 2

    "sales.sale_information.deposit.outright_sale" if @ownershipsch == 3
  end
end
