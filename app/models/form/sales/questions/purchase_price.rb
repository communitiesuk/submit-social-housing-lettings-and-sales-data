class Form::Sales::Questions::PurchasePrice < ::Form::Question
  def initialize(id, hsh, page, ownershipsch:)
    super(id, hsh, page)
    @id = "value"
    @type = "numeric"
    @min = 0
    @step = 0.01
    @width = 5
    @prefix = "£"
    @ownership_sch = ownershipsch
    @question_number = QUESTION_NUMBER_FROM_YEAR_AND_OWNERSHIP.fetch(form.start_date.year, QUESTION_NUMBER_FROM_YEAR_AND_OWNERSHIP.max_by { |k, _v| k }.last)[ownershipsch]
    @top_guidance_partial = top_guidance_partial
    @strip_commas = true
  end

  QUESTION_NUMBER_FROM_YEAR_AND_OWNERSHIP = {
    2023 => { 2 => 100, 3 => 110 },
    2024 => { 2 => 101, 3 => 111 },
    2025 => { 2 => 103 },
  }.freeze

  def copy_key
    case @ownership_sch
    when 2
      "sales.sale_information.purchase_price.discounted_ownership"
    when 3
      "sales.sale_information.purchase_price.outright_sale"
    end
  end

  def top_guidance_partial
    return "financial_calculations_discounted_ownership" if @ownership_sch == 2
    return "financial_calculations_outright_sale" if @ownership_sch == 3
  end
end
