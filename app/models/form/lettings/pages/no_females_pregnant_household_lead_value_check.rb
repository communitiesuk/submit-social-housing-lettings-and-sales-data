class Form::Lettings::Pages::NoFemalesPregnantHouseholdLeadValueCheck < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "no_females_pregnant_household_lead_value_check"
    @copy_key = "lettings.soft_validations.pregnancy_value_check.no_females_pregnant_household_value_check"
    @depends_on = [{ "all_male_tenants_in_a_pregnant_household?" => true }]
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
    if form.start_year_2026_or_later?
      %w[preg_occ sexrab1 gender_same_as_sex1 sexrab2 gender_same_as_sex2 sexrab3 gender_same_as_sex3 sexrab4 gender_same_as_sex4 sexrab5 gender_same_as_sex5 sexrab6 gender_same_as_sex6 sexrab7 gender_same_as_sex7 sexrab8 gender_same_as_sex8]
    else
      %w[preg_occ sex1 sex2 sex3 sex4 sex5 sex6 sex7 sex8]
    end
  end
end
