class Form::Sales::Pages::Mortgageused < ::Form::Page
  def questions
    @questions ||= [
      Form::Sales::Questions::Mortgageused.new(nil, nil, self),
    ]
  end
end
