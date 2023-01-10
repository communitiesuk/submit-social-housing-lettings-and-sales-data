class Form::Sales::Pages::LeaseholdCharges < ::Form::Page
  def questions
    @questions ||= [
      Form::Sales::Questions::LeaseholdChargesKnown.new(nil, nil, self),
      Form::Sales::Questions::LeaseholdCharges.new(nil, nil, self),
    ]
  end
end
