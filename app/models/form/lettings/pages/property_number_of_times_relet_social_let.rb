class Form::Lettings::Pages::PropertyNumberOfTimesReletSocialLet < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "property_number_of_times_relet_social_let"
    @depends_on = [{ "first_time_property_let_as_social_housing" => 1, "renewal" => 0 }]
  end

  def questions
    @questions ||= [Form::Lettings::Questions::OfferedSocialLet.new(nil, nil, self)]
  end
end
