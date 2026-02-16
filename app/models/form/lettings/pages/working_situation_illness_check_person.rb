class Form::Lettings::Pages::WorkingSituationIllnessCheckPerson < ::Form::Page
  def initialize(id, hsh, subsection, person_index:)
    super(id, hsh, subsection)
    @copy_key = "lettings.soft_validations.working_situation_illness_check"
    @depends_on = [{ "at_least_one_working_situation_is_sickness_and_household_sickness_is_no?" => true, "details_known_#{person_index}" => 0 }]
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
    @questions ||= [Form::Lettings::Questions::WorkingSituationIllnessCheck.new(nil, nil, self, person_index: @person_index)]
  end

  def interruption_screen_question_ids
    %w[illness ecstat1 ecstat2 ecstat3 ecstat4 ecstat5 ecstat6 ecstat7 ecstat8]
  end
end
