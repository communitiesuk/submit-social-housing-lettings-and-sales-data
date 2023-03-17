class Form::Sales::Pages::MortgageAmount < ::Form::Page
  def initialize(id, hsh, subsection, ownershipsch:)
    super(id, hsh, subsection)
    @ownershipsch = ownershipsch
    @header = "Mortgage Amount"
    @depends_on = [{
      "mortgageused" => 1,
    }]
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::MortgageAmount.new(nil, nil, self, ownershipsch: @ownershipsch),
    ]
  end
end
