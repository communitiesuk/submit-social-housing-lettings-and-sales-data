class Form::Sales::Pages::MortgageLength < ::Form::Page
  def initialize(id, hsh, subsection, question_number:)
    super(id, hsh, subsection)
    @depends_on = [{
      "mortgageused" => 1,
    }]
    @question_number = question_number
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::MortgageLength.new(nil, nil, self, question_number: @question_number),
    ]
  end
end
