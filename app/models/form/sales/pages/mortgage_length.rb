class Form::Sales::Pages::MortgageLength < ::Form::Page
  def initialize(id, hsh, subsection, ownershipsch:)
    super(id, hsh, subsection)
    @ownershipsch = ownershipsch
    @copy_key = "sales.sale_information.mortlen"
    @depends_on = [{
      "mortgageused" => 1,
    }]
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::MortgageLength.new(nil, nil, self, ownershipsch: @ownershipsch),
    ]
  end
end
