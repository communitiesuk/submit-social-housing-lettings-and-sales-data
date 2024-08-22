class Form::Sales::Pages::PurchasePriceOutrightOwnership < ::Form::Page
  def initialize(id, hsh, subsection, ownershipsch:)
    super(id, hsh, subsection)
    @depends_on = [
      { "outright_sale_or_discounted_with_full_ownership?" => true },
    ]
    @header = "About the price of the property"
    @top_guidance_partial = "financial_calculations_outright_sale"
    @ownershipsch = ownershipsch
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::PurchasePrice.new(nil, nil, self, ownershipsch: @ownershipsch),
    ]
  end
end
