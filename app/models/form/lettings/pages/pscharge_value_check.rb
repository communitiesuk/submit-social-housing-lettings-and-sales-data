class Form::Lettings::Pages::PschargeValueCheck < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "pscharge_value_check"
    @copy_key = "lettings.soft_validations.pscharge_value_check"
    @depends_on = [{ "pscharge_in_soft_max_range?" => true }]
    @title_text = {
      "translation" => "forms.#{form.start_date.year}.#{@copy_key}.title_text",
      "arguments" => [{
        "key" => "pscharge",
        "label" => true,
        "i18n_template" => "pscharge",
      }],
    }
    @informative_text = {
      "translation" => "forms.#{form.start_date.year}.#{@copy_key}.informative_text",
      "arguments" => [],
    }
  end

  def questions
    @questions ||= [Form::Lettings::Questions::PschargeValueCheck.new(nil, nil, self)]
  end

  def interruption_screen_question_ids
    %w[period needstype pscharge]
  end
end
