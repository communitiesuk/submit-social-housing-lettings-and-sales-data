class Form::Lettings::Pages::LeadTenantOverRetirementValueCheck < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @depends_on = [{ "person_1_not_retired_over_soft_max_age?" => true }]
    @copy_key = "lettings.soft_validations.retirement_value_check"
    @title_text = {
      "translation" => "forms.#{form.start_date.year}.#{@copy_key}.title_text",
    }
    @informative_text = {
      "translation" => "forms.#{form.start_date.year}.#{@copy_key}.informative_text",
      "arguments" => [],
    }
  end

  def questions
    @questions ||= [Form::Lettings::Questions::RetirementValueCheck.new(nil, nil, self, person_index: 1)]
  end

  def interruption_screen_question_ids
    %w[ecstat1 age1]
  end
end
