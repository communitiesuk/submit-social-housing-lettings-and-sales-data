class Form::Sales::Pages::RetirementValueCheck < Form::Sales::Pages::Person
  def initialize(id, hsh, subsection, person_index:)
    super
    @depends_on = [
      {
        "person_#{person_index}_retired_under_soft_min_age?" => true,
      },
    ]
    @person_index = person_index
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
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::RetirementValueCheck.new(nil, nil, self, person_index: @person_index),
    ]
  end

  def interruption_screen_question_ids
    ["age#{@person_index}", "ecstat#{@person_index}"]
  end
end
