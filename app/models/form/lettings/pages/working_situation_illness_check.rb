class Form::Lettings::Pages::WorkingSituationIllnessCheck < ::Form::Page
  def initialize(id, hsh, subsection)
    super(id, hsh, subsection)
    @id = "working_situation_long_term_illness_check"
    @copy_key = "lettings.soft_validations.working_situation_illness_check"
    @depends_on = [{ "at_least_one_working_situation_is_sickness_and_household_sickness_is_no?" => true }]
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
    @questions ||= [Form::Lettings::Questions::WorkingSituationIllnessCheck.new(nil, nil, self, person_index: 0)]
  end

  def interruption_screen_question_ids
    %w[illness ecstat1 ecstat2 ecstat3 ecstat4 ecstat5 ecstat6 ecstat7 ecstat8]
  end
end
