class Form::Lettings::Pages::SchargeValueCheck < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "scharge_value_check"
    @copy_key = "lettings.soft_validations.scharge_value_check"
    @depends_on = [{ "scharge_in_soft_max_range?" => true }]
    @title_text = {
      "translation" => "forms.#{form.start_date.year}.#{@copy_key}.title_text",
      "arguments" => [{
        "key" => "scharge",
        "label" => true,
        "i18n_template" => "scharge",
      }],
    }
    @title_text = {
      "translation" => "forms.#{form.start_date.year}.#{@copy_key}.informative_text",
      "arguments" => [],
    }
  end

  def questions
    @questions ||= [Form::Lettings::Questions::SchargeValueCheck.new(nil, nil, self)]
  end

  def interruption_screen_question_ids
    %w[period needstype scharge]
  end
end
