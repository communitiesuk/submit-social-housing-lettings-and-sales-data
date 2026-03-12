class Form::Sales::Questions::PurchasePrice < ::Form::Question
  def initialize(id, hsh, page, ownershipsch:)
    super(id, hsh, page)
    @id = "value"
    @type = "numeric"
    @min = form.start_year_2026_or_later? ? 15_000 : 0
    @step = 0.01
    @width = 5
    @prefix = "£"
    @ownership_sch = ownershipsch
    @question_number = get_question_number_from_hash(QUESTION_NUMBER_FROM_YEAR_AND_SECTION, value_key: form.start_year_2026_or_later? ? subsection.id : ownershipsch)
    @top_guidance_partial = top_guidance_partial
    @strip_commas = true
  end

  QUESTION_NUMBER_FROM_YEAR_AND_SECTION = {
    2023 => { 2 => 100, 3 => 110 },
    2024 => { 2 => 101, 3 => 111 },
    2025 => { 2 => 103 },
    2026 => { "discounted_ownership_scheme" => 113 },
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

    "financial_calculations_outright_sale" if @ownership_sch == 3
  end
end
