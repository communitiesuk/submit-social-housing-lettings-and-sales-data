class Form::Sales::Pages::PurchasePriceOutrightOwnership < ::Form::Page
  def initialize(id, hsh, subsection, ownershipsch:)
    super(id, hsh, subsection)
    @depends_on = [
      { "outright_sale_or_discounted_with_full_ownership?" => true },
    ]
    @top_guidance_partial = "financial_calculations_outright_sale"
    @ownershipsch = ownershipsch
  end

  def copy_key
    case @ownershipsch
    when 1
      "sales.sale_information.purchase_price.shared_ownership"
    when 2
      "sales.sale_information.purchase_price.discounted_ownership"
    when 3
      "sales.sale_information.purchase_price.outright_sale"
    end
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::PurchasePrice.new(nil, nil, self, ownershipsch: @ownershipsch),
    ]
  end
end
