class Form::Sales::Questions::MortgageAmount < ::Form::Question
  def initialize(id, hsh, subsection, ownershipsch:)
    super(id, hsh, subsection)
    @id = "mortgage"
    @copy_key = "sales.sale_information.mortgage"
    @type = "numeric"
    @min = 1
    @step = 1
    @width = 5
    @prefix = "£"
    @ownershipsch = ownershipsch
    @question_number = QUESTION_NUMBER_FROM_YEAR_AND_OWNERSHIP.fetch(form.start_date.year, QUESTION_NUMBER_FROM_YEAR_AND_OWNERSHIP.max_by { |k, _v| k }.last)[ownershipsch]
    @top_guidance_partial = top_guidance_partial
  end

  QUESTION_NUMBER_FROM_YEAR_AND_OWNERSHIP = {
    2023 => { 1 => 91, 2 => 104, 3 => 112 },
    2024 => { 1 => 92, 2 => 105, 3 => 113 },
  }.freeze

  def derived?(log)
    log&.mortgage_not_used?
  end

  def top_guidance_partial
    return "financial_calculations_shared_ownership" if @ownershipsch == 1
    return "financial_calculations_discounted_ownership" if @ownershipsch == 2
    return "financial_calculations_outright_sale" if @ownershipsch == 3
  end
end
