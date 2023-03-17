class Form::Sales::Pages::MortgageLenderOther < ::Form::Page
  def initialize(id, hsh, subsection, ownershipsch:)
    super(id, hsh, subsection)
    @ownershipsch = ownershipsch
    @header = ""
    @description = ""
    @subsection = subsection
    @depends_on = [{
      "mortgagelender" => 40,
    }]
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::MortgageLenderOther.new(nil, nil, self, ownershipsch: @ownershipsch),
    ]
  end
end
