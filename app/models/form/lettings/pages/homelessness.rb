class Form::Lettings::Pages::Homelessness < ::Form::Page
  def questions
    @questions ||= [Form::Lettings::Questions::Homeless.new(nil, nil, self)]
  end
end
