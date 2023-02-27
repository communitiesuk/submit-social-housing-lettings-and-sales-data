class Form::Sales::Pages::LeaseholdCharges < ::Form::Page
  def initialize(id, hsh, subsection, question_number:)
    super(id, hsh, subsection)
    @question_number = question_number
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::LeaseholdChargesKnown.new(nil, nil, self, question_number: @question_number),
      Form::Sales::Questions::LeaseholdCharges.new(nil, nil, self),
    ]
  end
end
