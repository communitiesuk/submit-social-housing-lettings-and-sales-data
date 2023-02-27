class Form::Sales::Pages::AboutDepositWithoutDiscount < ::Form::Page
  def initialize(id, hsh, subsection, question_number:)
    super(id, hsh, subsection)
    @header = "About the deposit"
    @depends_on = [{ "is_type_discount?" => false, "ownershipsch" => 1 },
                   { "ownershipsch" => 2 },
                   { "ownershipsch" => 3, "mortgageused" => 1 }]
    @question_number = question_number
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::DepositAmount.new(nil, nil, self, question_number: @question_number),
    ]
  end
end
