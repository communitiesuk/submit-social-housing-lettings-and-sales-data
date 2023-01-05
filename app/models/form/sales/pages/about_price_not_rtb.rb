class Form::Sales::Pages::AboutPriceNotRtb < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "about_price_not_rtb"
    @header = "About the price of the property"
    @description = ""
    @subsection = subsection
    @depends_on = [{
      "right_to_buy?" => false,
    }]
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::Value.new(nil, nil, self),
      Form::Sales::Questions::Grant.new(nil, nil, self),
    ]
  end
end
