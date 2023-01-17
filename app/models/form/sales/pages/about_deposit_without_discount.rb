class Form::Sales::Pages::AboutDepositWithoutDiscount < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @header = "About the deposit"
    @depends_on = [{ "is_type_discount?" => false, "ownershipsch" => 1 },
                   { "ownershipsch" => 2 },
                   { "ownershipsch" => 3, "mortgageused" => 1 }]
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::DepositAmount.new(nil, nil, self),
    ]
  end
end
