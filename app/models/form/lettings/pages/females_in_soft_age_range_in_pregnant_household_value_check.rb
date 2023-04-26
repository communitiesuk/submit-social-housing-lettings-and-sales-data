class Form::Lettings::Pages::FemalesInSoftAgeRangeInPregnantHouseholdValueCheck < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "females_in_soft_age_range_in_pregnant_household_value_check"
    @depends_on = [{ "female_in_pregnant_household_in_soft_validation_range?" => true }]
    @title_text = {
      "translation" => "soft_validations.pregnancy.title",
      "arguments" => [{ "key" => "sex1", "label" => true, "i18n_template" => "sex1" }],
    }
    @informative_text = {
      "translation" => "soft_validations.pregnancy.females_not_in_soft_age_range",
      "arguments" => [{ "key" => "sex1", "label" => true, "i18n_template" => "sex1" }],
    }
  end

  def questions
    @questions ||= [Form::Lettings::Questions::PregnancyValueCheck.new(nil, nil, self)]
  end

  def affected_question_ids
    %w[preg_occ sex1 sex2 sex3 sex4 sex5 sex6 sex7 sex8 age1 age2 age3 age4 age5 age6 age7 age8]
  end
end
