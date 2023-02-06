class Form::Lettings::Pages::HousingBenefit < ::Form::Page
  def questions
    @questions ||= [Form::Lettings::Questions::Hb.new(nil, nil, self)]
  end
end
