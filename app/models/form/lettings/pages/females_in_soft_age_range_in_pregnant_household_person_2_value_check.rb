class Form::Lettings::Pages::FemalesInSoftAgeRangeInPregnantHouseholdPerson2ValueCheck < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "females_in_soft_age_range_in_pregnant_household_person_2_value_check"
    @depends_on = [{ "female_in_pregnant_household_in_soft_validation_range?" => true, "details_known_2" => 0 }]
    @title_text = { "translation" => "soft_validations.pregnancy.title", "arguments" => [{ "key" => "sex1", "label" => true, "i18n_template" => "sex1" }] }
    @informative_text = { "translation" => "soft_validations.pregnancy.females_not_in_soft_age_range", "arguments" => [{ "key" => "sex1", "label" => true, "i18n_template" => "sex1" }] }
  end

  def questions
    @questions ||= [Form::Lettings::Questions::PregnancyValueCheck.new(nil, nil, self)]
  end
end
