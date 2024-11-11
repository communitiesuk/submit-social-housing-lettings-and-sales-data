class Form::Lettings::Pages::PersonUnderRetirementValueCheck < ::Form::Page
  def initialize(id, hsh, subsection, person_index:)
    super(id, hsh, subsection)
    @depends_on = [{ "person_#{person_index}_retired_under_soft_min_age?" => true }]
    @copy_key = "lettings.soft_validations.no_retirement_value_check"
    @title_text = {
      "translation" => "forms.#{form.start_date.year}.#{@copy_key}.title_text",
      "arguments" => [
        {
          "key" => "age#{person_index}",
          "label" => true,
          "i18n_template" => "age",
        },
      ],
    }
    @informative_text = {
      "translation" => "forms.#{form.start_date.year}.#{@copy_key}.informative_text",
      "arguments" => [],
    }
    @person_index = person_index
  end

  def questions
    @questions ||= [Form::Lettings::Questions::NoRetirementValueCheck.new(nil, nil, self, person_index: @person_index)]
  end

  def interruption_screen_question_ids
    ["ecstat#{@person_index}", "age#{@person_index}"]
  end
end
