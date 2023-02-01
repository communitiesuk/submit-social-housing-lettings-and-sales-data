class Form::Lettings::Pages::FirstTimePropertyLetAsSocialHousing < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "first_time_property_let_as_social_housing"
    @header = ""
    @depends_on = [{ "renewal" => 0 }]
    @description = ""
  end

  def questions
    @questions ||= [Form::Lettings::Questions::FirstTimePropertyLetAsSocialHousing.new(nil, nil, self)]
  end
end
