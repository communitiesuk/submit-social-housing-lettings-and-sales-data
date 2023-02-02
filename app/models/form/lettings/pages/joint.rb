class Form::Lettings::Pages::Joint < ::Form::Page
  def questions
    @questions ||= [Form::Lettings::Questions::Joint.new(nil, nil, self)]
  end
end
