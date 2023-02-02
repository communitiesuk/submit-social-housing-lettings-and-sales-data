class Form::Lettings::Pages::PreviousPostcode < ::Form::Page
  def questions
    @questions ||= [
      Form::Lettings::Questions::Ppcodenk.new(nil, nil, self),
      Form::Lettings::Questions::PpostcodeFull.new(nil, nil, self),
    ]
  end
end
