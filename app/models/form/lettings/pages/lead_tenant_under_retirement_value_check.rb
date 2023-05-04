class Form::Lettings::Pages::LeadTenantUnderRetirementValueCheck < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "lead_tenant_under_retirement_value_check"
    @depends_on = [{ "person_1_retired_under_soft_min_age?" => true }]
    @title_text = {
      "translation" => "soft_validations.retirement.min.title",
      "arguments" => [
        {
          "key" => "age1",
          "label" => true,
          "i18n_template" => "age",
        },
      ],
    }
    @informative_text = {}
  end

  def questions
    @questions ||= [Form::Lettings::Questions::NoRetirementValueCheck.new(nil, nil, self, person_index: 1)]
  end

  def interruption_screen_question_ids
    %w[ecstat1 age1]
  end
end
