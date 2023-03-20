class Form::Sales::Pages::AboutPriceNotRtb < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "about_price_not_rtb"
    @header = "About the price of the property"
    @depends_on = [{
      "right_to_buy?" => false,
      "rent_to_buy_full_ownership?" => false,
    }]
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::PurchasePrice.new(nil, nil, self, ownershipsch: 2),
      Form::Sales::Questions::Grant.new(nil, nil, self),
    ]
  end
end
