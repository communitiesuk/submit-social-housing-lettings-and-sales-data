class Form::Sales::Pages::PurchasePriceOutrightOwnership < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @depends_on = [
      { "outright_sale_or_discounted_with_full_ownership?" => true },
    ]
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::PurchasePriceOutrightOwnership.new(nil, nil, self),
    ]
  end
end
