class Form::Lettings::Pages::FemalesInSoftAgeRangeInPregnantHouseholdPersonValueCheck < ::Form::Page
  def initialize(id, hsh, subsection, person_index:)
    super(id, hsh, subsection)
    @id = "females_in_soft_age_range_in_pregnant_household_person_#{person_index}_value_check"
    @copy_key = "lettings.soft_validations.pregnancy_value_check.females_in_soft_age_range_in_pregnant_household_value_check"

    @depends_on = [
      {
        "non_males_in_pregnant_household_not_in_pregnancy_range?" => true,
        "details_known_#{person_index}" => 0,
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
    %w[preg_occ sex1 sex2 sex3 sex4 sex5 sex6 sex7 sex8 age1 age2 age3 age4 age5 age6 age7 age8]
  end
end
