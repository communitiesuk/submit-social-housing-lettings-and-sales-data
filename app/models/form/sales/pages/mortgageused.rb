class Form::Sales::Pages::Mortgageused < ::Form::Page
  def initialize(id, hsh, form, question_number:)
    super(id, hsh, form)
    @question_number = question_number
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::Mortgageused.new(nil, nil, self, question_number: @question_number),
    ]
  end
end
