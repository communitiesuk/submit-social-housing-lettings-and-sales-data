class Form::Lettings::Pages::BenefitsProportion < ::Form::Page
  def questions
    @questions ||= [Form::Lettings::Questions::Benefits.new(nil, nil, self)]
  end
end
