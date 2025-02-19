class Form::Lettings::Pages::PropertyNumberOfTimesRelet < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "property_number_of_times_relet"
    @depends_on = [{ "first_time_property_let_as_social_housing" => 0, "is_renewal?" => false },
                   { "first_time_property_let_as_social_housing" => 1, "is_renewal?" => false }]
  end

  def questions
    @questions ||= [Form::Lettings::Questions::Offered.new(nil, nil, self)]
  end
end
