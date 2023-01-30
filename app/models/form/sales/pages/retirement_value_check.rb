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
          "key" => "retirement_age_for_person_#{person_index}",
          "label" => false,
          "i18n_template" => "age",
        },
      ],
    }
    @informative_text = {
      "translation" => "soft_validations.retirement.min.hint_text",
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
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::RetirementValueCheck.new(nil, nil, self, person_index: @person_index),
    ]
  end
end
