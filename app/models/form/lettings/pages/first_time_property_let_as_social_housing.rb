class Form::Lettings::Pages::FirstTimePropertyLetAsSocialHousing < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "first_time_property_let_as_social_housing"
    @depends_on = [{ "not_renewal?" => true }]
  end

  def questions
    @questions ||= [Form::Lettings::Questions::FirstTimePropertyLetAsSocialHousing.new(nil, nil, self)]
  end
end
