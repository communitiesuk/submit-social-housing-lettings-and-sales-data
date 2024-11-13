class Form::Lettings::Pages::LeadTenantUnderRetirementValueCheck < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @depends_on = [{ "person_1_retired_under_soft_min_age?" => true }]
    @copy_key = "lettings.soft_validations.no_retirement_value_check"
    @title_text = {
      "translation" => "forms.#{form.start_date.year}.#{@copy_key}.title_text",
      "arguments" => [
        {
          "key" => "age1",
          "label" => true,
          "i18n_template" => "age",
        },
      ],
    }
    @informative_text = {
      "translation" => "forms.#{form.start_date.year}.#{@copy_key}.informative_text",
      "arguments" => [],
    }
  end

  def questions
    @questions ||= [Form::Lettings::Questions::NoRetirementValueCheck.new(nil, nil, self, person_index: 1)]
  end

  def interruption_screen_question_ids
    %w[ecstat1 age1]
  end
end
