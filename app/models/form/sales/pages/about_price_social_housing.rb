class Form::Sales::Pages::AboutPriceSocialHousing < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "about_price_social_housing"
    @header = "About the price of the property"
    @description = ""
    @subsection = subsection
    @depends_on = [{
      "soctenant" => 1,
    }]
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::Value.new(nil, nil, self),
      Form::Sales::Questions::Equity.new(nil, nil, self),
    ]
  end
end
