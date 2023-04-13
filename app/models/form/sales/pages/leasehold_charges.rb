class Form::Sales::Pages::LeaseholdCharges < ::Form::Page
  def initialize(id, hsh, subsection, ownershipsch:)
    super(id, hsh, subsection)
    @ownershipsch = ownershipsch
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::HasLeaseholdCharges.new(nil, nil, self, ownershipsch: @ownershipsch),
      Form::Sales::Questions::LeaseholdCharges.new(nil, nil, self, ownershipsch: @ownershipsch),
    ]
  end
end
