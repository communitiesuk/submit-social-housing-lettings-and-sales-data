class Form::Sales::Pages::AboutPriceRtb < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "about_price_rtb"
    @header = "About the price of the property"
    @description = ""
    @subsection = subsection
    @depends_on = [{
      "right_to_buy?" => true,
    }]
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::Value.new(nil, nil, self),
      Form::Sales::Questions::Discount.new(nil, nil, self),
    ]
  end
end
