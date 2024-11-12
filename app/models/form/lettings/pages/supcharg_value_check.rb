class Form::Lettings::Pages::SupchargValueCheck < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "supcharg_value_check"
    @copy_key = "lettings.soft_validations.supcharg_value_check"
    @depends_on = [{ "supcharg_in_soft_max_range?" => true }]
    @title_text = {
      "translation" => "forms.#{form.start_date.year}.#{@copy_key}.title_text",
      "arguments" => [{
        "key" => "supcharg",
        "label" => true,
        "i18n_template" => "supcharg",
      }],
    }
    @informative_text = {
      "translation" => "forms.#{form.start_date.year}.#{@copy_key}.informative_text",
      "arguments" => [],
    }
  end

  def questions
    @questions ||= [Form::Lettings::Questions::SupchargValueCheck.new(nil, nil, self)]
  end

  def interruption_screen_question_ids
    %w[period needstype supcharg]
  end
end
