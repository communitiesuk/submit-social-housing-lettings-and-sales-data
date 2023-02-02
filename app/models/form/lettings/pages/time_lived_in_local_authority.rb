class Form::Lettings::Pages::TimeLivedInLocalAuthority < ::Form::Page
  def questions
    @questions ||= [Form::Lettings::Questions::Layear.new(nil, nil, self)]
  end
end
