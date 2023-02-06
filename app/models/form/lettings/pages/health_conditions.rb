class Form::Lettings::Pages::HealthConditions < ::Form::Page
  def questions
    @questions ||= [Form::Lettings::Questions::Illness.new(nil, nil, self)]
  end
end
