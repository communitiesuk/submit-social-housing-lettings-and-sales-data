class Form::Sales::Pages::AboutDepositWithDiscount < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "about_deposit_with_discount"
    @header = "About the deposit"
    @description = ""
    @subsection = subsection
    @depends_on = [{ "type" => 18 }]
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::DepositAmount.new(nil, nil, self),
      Form::Sales::Questions::DepositDiscount.new(nil, nil, self),
    ]
  end
end
