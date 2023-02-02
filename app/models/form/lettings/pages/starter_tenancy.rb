class Form::Lettings::Pages::StarterTenancy < ::Form::Page
  def questions
    @questions ||= [Form::Lettings::Questions::Startertenancy.new(nil, nil, self)]
  end
end
