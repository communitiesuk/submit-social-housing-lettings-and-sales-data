class Form::Lettings::Pages::Pregnant < ::Form::Page
  def questions
    @questions ||= [Form::Lettings::Questions::PregOcc.new(nil, nil, self)]
  end
end
