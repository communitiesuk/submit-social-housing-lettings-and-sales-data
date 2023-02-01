class Form::Lettings::Pages::PropertyNumberOfTimesReletNotSocialLet < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "property_number_of_times_relet_not_social_let"
    @header = ""
    @depends_on = [{ "first_time_property_let_as_social_housing" => 0, "renewal" => 0 }]
    @description = ""
  end

  def questions
    @questions ||= [Form::Lettings::Questions::Offered.new(nil, nil, self)]
  end
end
