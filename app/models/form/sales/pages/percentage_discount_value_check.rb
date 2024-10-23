class Form::Sales::Pages::PercentageDiscountValueCheck < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @depends_on = [{ "percentage_discount_invalid?" => true }]
    @copy_key = "sales.soft_validations.percentage_discount_value_check"
    @title_text = {
      "translation" => "forms.#{form.start_date.year}.#{@copy_key}.title_text",
      "arguments" => [{ "key" => "discount", "label" => true, "i18n_template" => "discount" }],
    }
    @informative_text = {
      "translation" => "forms.#{form.start_date.year}.#{@copy_key}.hint_text",
      "arguments" => [],
    }
  end

  def questions
    @questions ||= [Form::Sales::Questions::PercentageDiscountValueCheck.new(nil, nil, self)]
  end

  def interruption_screen_question_ids
    %w[discount proptype]
  end
end
