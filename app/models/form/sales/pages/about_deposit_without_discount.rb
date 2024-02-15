class Form::Sales::Pages::AboutDepositWithoutDiscount < ::Form::Page
  def initialize(id, hsh, subsection, ownershipsch:, optional:)
    super(id, hsh, subsection)
    @header = "About the deposit"
    @ownershipsch = ownershipsch
    @optional = optional
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::DepositAmount.new(nil, nil, self, ownershipsch: @ownershipsch, optional: @optional),
    ]
  end

  def depends_on
    if form.start_year_after_2024?
      [{ "is_type_discount?" => false, "ownershipsch" => 1, "stairowned_100?" => @optional },
       { "ownershipsch" => 2 },
       { "ownershipsch" => 3, "mortgageused" => 1 }]
    else
      [{ "is_type_discount?" => false, "ownershipsch" => 1 },
       { "ownershipsch" => 2 },
       { "ownershipsch" => 3, "mortgageused" => 1 }]
    end
  end
end
