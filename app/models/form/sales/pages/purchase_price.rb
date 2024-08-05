class Form::Sales::Pages::PurchasePrice < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "purchase_price"
    @header = "About the price of the property"
    @depends_on = [{
      "right_to_buy?" => true,
    }]
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::PurchasePrice.new(nil, nil, self, ownershipsch: 2),
    ]
  end
end
