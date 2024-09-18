class Form::Lettings::Pages::NoFemalesPregnantHouseholdValueCheck < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "no_females_pregnant_household_value_check"
    @depends_on = [{ "all_male_tenants_in_a_pregnant_household?" => true }]
    @title_text = {
      "translation" => "soft_validations.pregnancy.title",
      "arguments" => [{ "key" => "sex1", "label" => true, "i18n_template" => "sex1" }],
    }
    @informative_text = {
      "translation" => "soft_validations.pregnancy.all_male_tenants",
      "arguments" => [{ "key" => "sex1", "label" => true, "i18n_template" => "sex1" }],
    }
  end

  def questions
    @questions ||= [Form::Lettings::Questions::PregnancyValueCheck.new(nil, nil, self, person_index: 0)]
  end

  def interruption_screen_question_ids
    %w[preg_occ sex1 sex2 sex3 sex4 sex5 sex6 sex7 sex8]
  end
end
