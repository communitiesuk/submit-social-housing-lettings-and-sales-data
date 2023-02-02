class Form::Lettings::Pages::ReasonablePreference < ::Form::Page
  def questions
    @questions ||= [Form::Lettings::Questions::Reasonpref.new(nil, nil, self)]
  end
end
