class Form::Lettings::Pages::PersonUnderRetirementValueCheck < ::Form::Page
  def initialize(id, hsh, subsection, person_index:)
    super(id, hsh, subsection)
    @id = "person_#{person_index}_under_retirement_value_check"
    @depends_on = [{ "person_#{person_index}_retired_under_soft_min_age?" => true }]
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
    @questions ||= [Form::Lettings::Questions::NoRetirementValueCheck.new(nil, nil, self)]
  end
end
