class Form::Sales::Pages::MortgageLengthNotInterviewed < ::Form::Page
  def initialize(id, hsh, subsection, ownershipsch:)
    super(id, hsh, subsection)
    @ownershipsch = ownershipsch
    @depends_on = [
      { "mortgageused" => 1, "buyer_not_interviewed?" => true },
    ]
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::MortgageLength.new(nil, nil, self, ownershipsch: @ownershipsch),
    ]
  end
end
