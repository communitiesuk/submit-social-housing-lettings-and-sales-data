class Form::Lettings::Pages::NoFemalesPregnantHouseholdPerson6AgeValueCheck < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "no_females_pregnant_household_person_6_age_value_check"
    @depends_on = [{ "no_females_in_a_pregnant_household?" => true, "age6_known" => 0 }]
    @title_text = { "translation" => "soft_validations.pregnancy.title", "arguments" => [{ "key" => "sex1", "label" => true, "i18n_template" => "sex1" }] }
    @informative_text = { "translation" => "soft_validations.pregnancy.no_females", "arguments" => [{ "key" => "sex1", "label" => true, "i18n_template" => "sex1" }] }
  end

  def questions
    @questions ||= [Form::Lettings::Questions::PregnancyValueCheck.new(nil, nil, self)]
  end
end
