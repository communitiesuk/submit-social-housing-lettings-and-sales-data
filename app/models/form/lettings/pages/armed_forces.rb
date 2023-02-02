class Form::Lettings::Pages::ArmedForces < ::Form::Page
  def questions
    @questions ||= [Form::Lettings::Questions::Armedforces.new(nil, nil, self)]
  end
end
