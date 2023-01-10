class Form::Sales::Pages::LeaseholdCharges < ::Form::Page
  def initialize(id, hsh, subsection)
    super
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::LeaseholdChargesKnown.new(nil, nil, self),
      Form::Sales::Questions::LeaseholdCharges.new(nil, nil, self),
    ]
  end
end
