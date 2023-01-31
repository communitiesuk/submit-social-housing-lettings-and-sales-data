class Form::Sales::Pages::AboutPriceRtb < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "about_price_rtb"
    @header = "About the price of the property"
    @depends_on = [{
      "right_to_buy?" => true,
    }]
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::PurchasePriceDiscountedOwnership.new(nil, nil, self),
      Form::Sales::Questions::Discount.new(nil, nil, self),
    ]
  end
end
