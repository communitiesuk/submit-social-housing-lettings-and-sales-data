class Form::Sales::Pages::MortgageLength < ::Form::Page
  def questions
    @questions ||= [
      Form::Sales::Questions::MortgageLength.new(nil, nil, self),
    ]
  end
end
