class Form::Lettings::Pages::NoFemalesPregnantHouseholdLeadAgeValueCheck < ::Form::Page
  def initialize(id, hsh, subsection)
    super(id, hsh, subsection)
    @id = "no_females_pregnant_household_lead_age_value_check"
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
    %w[preg_occ sex1 sex2 sex3 sex4 sex5 sex6 sex7 sex8]
  end
end
