class Form::Lettings::Pages::LeadTenantOverRetirementValueCheck < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @depends_on = [{ "person_1_not_retired_over_soft_max_age?" => true }]
    @title_text = {
      "translation" => "soft_validations.retirement.max.title",
    }
    @informative_text = {
      "translation" => "soft_validations.retirement.max.hint_text",
    }
  end

  def questions
    @questions ||= [Form::Lettings::Questions::RetirementValueCheck.new(nil, nil, self, person_index: 1)]
  end

  def interruption_screen_question_ids
    %w[ecstat1 age1]
  end
end
