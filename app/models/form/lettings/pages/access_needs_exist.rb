class Form::Lettings::Pages::AccessNeedsExist < ::Form::Page
  def questions
    @questions ||= [Form::Lettings::Questions::Housingneeds.new(nil, nil, self)]
  end
end
