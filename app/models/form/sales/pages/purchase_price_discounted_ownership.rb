class Form::Sales::Pages::PurchasePriceDiscountedOwnership < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @depends_on = [
      { "ownershipsch" => 2 },
    ]
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::PurchasePriceDiscountedOwnership.new(nil, nil, self),
    ]
  end
end
