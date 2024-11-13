class Form::Lettings::Pages::PersonOverRetirementValueCheck < ::Form::Page
  def initialize(id, hsh, subsection, person_index:)
    super(id, hsh, subsection)
    @depends_on = [{ "person_#{person_index}_not_retired_over_soft_max_age?" => true }]
    @copy_key = "lettings.soft_validations.retirement_value_check"
    @title_text = {
      "translation" => "forms.#{form.start_date.year}.#{@copy_key}.title_text",
    }
    @informative_text = {
      "translation" => "forms.#{form.start_date.year}.#{@copy_key}.informative_text",
      "arguments" => [],
    }
    @person_index = person_index
  end

  def questions
    @questions ||= [Form::Lettings::Questions::RetirementValueCheck.new(nil, nil, self, person_index: @person_index)]
  end

  def interruption_screen_question_ids
    ["ecstat#{@person_index}", "age#{@person_index}"]
  end
end
