class Form::Sales::Pages::AboutPriceSharedOwnership < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "about_price_shared_ownership"
    @header = "About the price of the property"
    @description = ""
    @subsection = subsection
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::Value.new(nil, nil, self),
      Form::Sales::Questions::Equity.new(nil, nil, self),
    ]
  end
end
