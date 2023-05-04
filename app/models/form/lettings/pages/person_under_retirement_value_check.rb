class Form::Lettings::Pages::PersonUnderRetirementValueCheck < ::Form::Page
  def initialize(id, hsh, subsection, person_index:)
    super(id, hsh, subsection)
    @id = "person_#{person_index}_under_retirement_value_check"
    @depends_on = [{ "person_#{person_index}_retired_under_soft_min_age?" => true }]
    @title_text = {
      "translation" => "soft_validations.retirement.min.title",
      "arguments" => [
        {
          "key" => "age#{person_index}",
          "label" => true,
          "i18n_template" => "age",
        },
      ],
    }
    @informative_text = {}
    @person_index = person_index
  end

  def questions
    @questions ||= [Form::Lettings::Questions::NoRetirementValueCheck.new(nil, nil, self, person_index: @person_index)]
  end

  def interruption_screen_question_ids
    ["ecstat#{@person_index}", "age#{@person_index}"]
  end
end
