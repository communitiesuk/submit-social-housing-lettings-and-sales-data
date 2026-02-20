class Form::Lettings::Pages::NoHouseholdMemberLikelyToBePregnantCheck < ::Form::Page
  def initialize(id, hsh, subsection, person_index: 0)
    super(id, hsh, subsection)
    @copy_key = "lettings.soft_validations.pregnancy_value_check.no_household_member_likely_to_be_pregnant_check"
    @depends_on = [{ "no_household_member_likely_to_be_pregnant?" => true }]
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
    %w[preg_occ age1 sexrab1 gender_same_as_sex1 age2 sexrab2 gender_same_as_sex2 age3 sexrab3 gender_same_as_sex3 age4 sexrab4 gender_same_as_sex4 age5 sexrab5 gender_same_as_sex5 age6 sexrab6 gender_same_as_sex6 age7 sexrab7 gender_same_as_sex7 age8 sexrab8 gender_same_as_sex8]
  end
end
