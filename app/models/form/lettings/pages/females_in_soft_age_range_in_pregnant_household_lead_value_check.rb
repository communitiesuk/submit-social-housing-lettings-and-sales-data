class Form::Lettings::Pages::FemalesInSoftAgeRangeInPregnantHouseholdLeadValueCheck < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "females_in_soft_age_range_in_pregnant_household_lead_value_check"
    @copy_key = "lettings.soft_validations.pregnancy_value_check.females_in_soft_age_range_in_pregnant_household_value_check"
    @depends_on = [{ "non_males_in_pregnant_household_not_in_pregnancy_range?" => true }]
    @title_text = {
      "translation" => "forms.#{form.start_date.year}.#{@copy_key}.title_text",
      "arguments" => [],
    }
    @informative_text = {
      "translation" => "forms.#{form.start_date.year}.#{@copy_key}.informative_text",
      "arguments" => [],
    }
  end

  def questions
    @questions ||= [Form::Lettings::Questions::PregnancyValueCheck.new(nil, nil, self, person_index: 1)]
  end

  def interruption_screen_question_ids
    %w[preg_occ sex1 sex2 sex3 sex4 sex5 sex6 sex7 sex8 age1 age2 age3 age4 age5 age6 age7 age8]
  end
end
