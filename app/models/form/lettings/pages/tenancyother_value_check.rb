class Form::Lettings::Pages::TenancyotherValueCheck < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "tenancyother_value_check"
    @copy_key = "lettings.soft_validations.tenancyother_value_check"
    @depends_on = [{ "tenancyother_might_be_introductory_or_starter_period?" => true }]
    @title_text = {
      "translation" => "forms.#{form.start_date.year}.#{@copy_key}.title_text",
      "arguments" => [{ "key" => "tenancyother", "i18n_template" => "tenancyother" }],
    }
    @informative_text = {
      "translation" => "forms.#{form.start_date.year}.#{@copy_key}.informative_text",
      "arguments" => [],
    }
  end

  def questions
    @questions ||= [Form::Lettings::Questions::TenancyotherValueCheck.new(nil, nil, self)]
  end

  def interruption_screen_question_ids
    %w[tenancy tenancyother]
  end
end
