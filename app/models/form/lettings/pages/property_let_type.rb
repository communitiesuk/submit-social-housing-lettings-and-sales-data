class Form::Lettings::Pages::PropertyLetType < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "property_let_type"
    @depends_on = [{ "first_time_property_let_as_social_housing" => 0, "renewal" => 0 }]
  end

  def questions
    @questions ||= [Form::Lettings::Questions::PreviousLetType.new(nil, nil, self)]
  end
end
