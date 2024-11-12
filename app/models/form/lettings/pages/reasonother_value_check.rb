class Form::Lettings::Pages::ReasonotherValueCheck < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "reasonother_value_check"
    @copy_key = "lettings.soft_validations.reasonother_value_check"
    @depends_on = [{ "reasonother_might_be_existing_category?" => true }]
    @title_text = {
      "translation" => "forms.#{form.start_date.year}.#{@copy_key}.title_text",
      "arguments" => [{ "key" => "reasonother", "i18n_template" => "reasonother" }],
    }
    @informative_text = {
      "translation" => "forms.#{form.start_date.year}.#{@copy_key}.informative_text",
      "arguments" => [],
    }
  end

  def questions
    @questions ||= [Form::Lettings::Questions::ReasonotherValueCheck.new(nil, nil, self)]
  end

  def interruption_screen_question_ids
    %w[reason reasonother]
  end
end
