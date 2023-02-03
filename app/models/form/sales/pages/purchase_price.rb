class Form::Sales::Pages::PurchasePrice < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @depends_on = [
      { "ownershipsch" => 2, "rent_to_buy_full_ownership?" => false },
    ]
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::PurchasePrice.new(nil, nil, self),
    ]
  end
end
