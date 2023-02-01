class Form::Lettings::Pages::PropertyLetType < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "property_let_type"
    @header = ""
    @depends_on = [{ "first_time_property_let_as_social_housing" => 0, "renewal" => 0, "needstype" => 1 }]
    @description = ""
  end

  def questions
    @questions ||= [Form::Lettings::Questions::Unitletas.new(nil, nil, self)]
  end
end
