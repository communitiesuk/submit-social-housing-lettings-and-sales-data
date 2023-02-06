class Form::Lettings::Pages::PropertyVacancyReasonNotFirstLet < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "property_vacancy_reason_not_first_let"
    @depends_on = [{ "first_time_property_let_as_social_housing" => 0, "renewal" => 0 }]
  end

  def questions
    @questions ||= [Form::Lettings::Questions::Rsnvac.new(nil, nil, self)]
  end
end
