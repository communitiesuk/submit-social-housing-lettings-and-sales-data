class Form::Sales::Pages::PurchasePrice < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "purchase_price"
    @copy_key = "sales.sale_information.purchase_price.discounted_ownership"
    @depends_on = [{ "right_to_buy?" => true },
                   {
                     "right_to_buy?" => false,
                     "rent_to_buy_full_ownership?" => false,
                   }]
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::PurchasePrice.new(nil, nil, self, ownershipsch: 2),
    ]
  end
end
