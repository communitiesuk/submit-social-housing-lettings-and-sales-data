class Form::Sales::Pages::MortgageAmount < ::Form::Page
  def initialize(id, hsh, subsection, question_number)
    super(id, hsh, subsection)
    @header = "Mortgage Amount"
    @depends_on = [{
      "mortgageused" => 1,
    }]
    @question_number = question_number
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::MortgageAmount.new(nil, nil, self, question_number: @question_number),
    ]
  end
end
