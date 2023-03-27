class Form::Sales::Pages::MortgageAmount < ::Form::Page
  def initialize(id, hsh, subsection, ownershipsch:)
    super(id, hsh, subsection)
    @ownershipsch = ownershipsch
    @header = "Mortgage Amount"
    @depends_on = [{ "mortgage_used?" => true }]
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::MortgageAmount.new(nil, nil, self, ownershipsch: @ownershipsch),
    ]
  end
end
