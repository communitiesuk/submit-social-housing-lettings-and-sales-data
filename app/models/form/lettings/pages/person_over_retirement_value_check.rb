class Form::Lettings::Pages::PersonOverRetirementValueCheck < ::Form::Page
  def initialize(id, hsh, subsection, person_index:)
    super(id, hsh, subsection)
    @id = "person_#{person_index}_over_retirement_value_check"
    @depends_on = [{ "person_#{person_index}_not_retired_over_soft_max_age?" => true }]
    @title_text = {
      "translation" => "soft_validations.retirement.max.title",
      "arguments" => [
        {
          "key" => "retirement_age_for_person_#{person_index}",
          "label" => false,
          "i18n_template" => "age",
        },
      ],
    }
    @informative_text = {
      "translation" => "soft_validations.retirement.max.hint_text",
      "arguments" => [
        {
          "key" => "plural_gender_for_person_#{person_index}",
          "label" => false,
          "i18n_template" => "gender",
        },
        {
          "key" => "retirement_age_for_person_#{person_index}",
          "label" => false,
          "i18n_template" => "age",
        },
      ],
    }
    @person_index = person_index
  end

  def questions
    @questions ||= [Form::Lettings::Questions::RetirementValueCheck.new(nil, nil, self)]
  end

  def affected_question_ids
    ["ecstat#{@person_index}", "sex#{@person_index}", "age#{@person_index}"]
  end
end
