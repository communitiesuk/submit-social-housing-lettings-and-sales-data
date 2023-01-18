class Form::Sales::Pages::AboutDepositWithDiscount < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "about_deposit_with_discount"
    @header = "About the deposit"
    @depends_on = [{ "is_type_discount?" => true }]
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::DepositAmount.new(nil, nil, self),
      Form::Sales::Questions::DepositDiscount.new(nil, nil, self),
    ]
  end
end
