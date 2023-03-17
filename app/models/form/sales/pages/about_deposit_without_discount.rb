class Form::Sales::Pages::AboutDepositWithoutDiscount < ::Form::Page
  def initialize(id, hsh, subsection, ownershipsch:)
    super(id, hsh, subsection)
    @header = "About the deposit"
    @depends_on = [{ "is_type_discount?" => false, "ownershipsch" => 1 },
                   { "ownershipsch" => 2 },
                   { "ownershipsch" => 3, "mortgageused" => 1 }]
    @ownershipsch = ownershipsch
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::DepositAmount.new(nil, nil, self, ownershipsch: @ownershipsch),
    ]
  end
end
