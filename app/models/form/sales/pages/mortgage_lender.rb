class Form::Sales::Pages::MortgageLender < ::Form::Page
  def initialize(id, hsh, subsection, question_number)
    super(id, hsh, subsection)
    @header = ""
    @description = ""
    @subsection = subsection
    @depends_on = [{
      "mortgageused" => 1,
    }]
    @question_number = question_number
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::MortgageLender.new(nil, nil, self, question_number: @question_number),
    ]
  end
end
