class Form::Lettings::Pages::Person8OverRetirementValueCheck < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "person_8_over_retirement_value_check"
    @depends_on = [{ "person_8_not_retired_over_soft_max_age?" => true }]
    @title_text = { "translation" => "soft_validations.retirement.max.title", "arguments" => [{ "key" => "retirement_age_for_person_8", "label" => false, "i18n_template" => "age" }] }
    @informative_text = { "translation" => "soft_validations.retirement.max.hint_text", "arguments" => [{ "key" => "plural_gender_for_person_8", "label" => false, "i18n_template" => "gender" }, { "key" => "retirement_age_for_person_8", "label" => false, "i18n_template" => "age" }] }
  end

  def questions
    @questions ||= [Form::Lettings::Questions::RetirementValueCheck.new(nil, nil, self)]
  end
end
