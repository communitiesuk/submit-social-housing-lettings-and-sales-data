class Form::Lettings::Pages::FemalesInSoftAgeRangeInPregnantHouseholdPersonAgeValueCheck < ::Form::Page
  def initialize(id, hsh, subsection, person_index:)
    super(id, hsh, subsection)
    @id = "females_in_soft_age_range_in_pregnant_household_person_#{person_index}_age_value_check"
    @copy_key = "lettings.soft_validations.pregnancy_value_check.females_in_soft_age_range_in_pregnant_household_value_check"
    @depends_on = [
      {
        "non_males_in_pregnant_household_in_soft_validation_range?" => true,
        "age#{person_index}_known" => 0,
      },
    ]
    @title_text = {
      "translation" => "forms.#{form.start_date.year}.#{@copy_key}.title_text",
      "arguments" => [],
    }
    @informative_text = {
      "translation" => "forms.#{form.start_date.year}.#{@copy_key}.informative_text",
      "arguments" => [],
    }
    @person_index = person_index
  end

  def questions
    @questions ||= [Form::Lettings::Questions::PregnancyValueCheck.new(nil, nil, self, person_index: @person_index)]
  end

  def interruption_screen_question_ids
    if form.start_year_2026_or_later?
      %w[preg_occ age1 sexrab1 gender_same_as_sex1 age2 sexrab2 gender_same_as_sex2 age3 sexrab3 gender_same_as_sex3 age4 sexrab4 gender_same_as_sex4 age5 sexrab5 gender_same_as_sex5 age6 sexrab6 gender_same_as_sex6 age7 sexrab7 gender_same_as_sex7 age8 sexrab8 gender_same_as_sex8]
    else
      %w[preg_occ sex1 sex2 sex3 sex4 sex5 sex6 sex7 sex8 age1 age2 age3 age4 age5 age6 age7 age8]
    end
  end
end
