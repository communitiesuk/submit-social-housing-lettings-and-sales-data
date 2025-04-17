class Form::Sales::Questions::DepositAmount < ::Form::Question
  def initialize(id, hsh, subsection, ownershipsch:, optional:)
    super(id, hsh, subsection)
    @id = "deposit"
    @type = "numeric"
    @min = 0
    @max = 999_999
    @step = 1
    @width = 5
    @prefix = "£"
    @ownershipsch = ownershipsch
    @question_number = QUESTION_NUMBER_FROM_YEAR_AND_OWNERSHIP.fetch(form.start_date.year, QUESTION_NUMBER_FROM_YEAR_AND_OWNERSHIP.max_by { |k, _v| k }.last)[ownershipsch]
    @optional = optional
    @top_guidance_partial = top_guidance_partial
    @copy_key = copy_key
  end

  def derived?(log)
    log.outright_sale? && !log.mortgage_used?
  end

  QUESTION_NUMBER_FROM_YEAR_AND_OWNERSHIP = {
    2023 => { 1 => 95, 2 => 108, 3 => 116 },
    2024 => { 1 => 96, 2 => 109, 3 => 116 },
    2025 => { 1 => 85, 2 => 110 },
  }.freeze

  def top_guidance_partial
    return "financial_calculations_shared_ownership" if @ownershipsch == 1
    return "financial_calculations_discounted_ownership" if @ownershipsch == 2
    return "financial_calculations_outright_sale" if @ownershipsch == 3
  end

  def copy_key
    return "sales.sale_information.deposit.shared_ownership" if @ownershipsch == 1
    return "sales.sale_information.deposit.discounted_ownership" if @ownershipsch == 2
    return "sales.sale_information.deposit.outright_sale" if @ownershipsch == 3
  end
end
