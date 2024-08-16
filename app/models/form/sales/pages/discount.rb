class Form::Sales::Pages::Discount < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "discount"
    @header = "About the price of the property"
    @depends_on = [{
      "right_to_buy?" => true,
    }]
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::Discount.new(nil, nil, self),
    ]
  end
end
