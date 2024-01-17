class Form::Lettings::Pages::NetIncomeValueCheck < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "net_income_value_check"
    @depends_on = [{ "net_income_soft_validation_triggered?" => true }]
    @title_text = {
      "translation" => "soft_validations.net_income.title_text",
      "arguments" => [
        {
          "key" => "incfreq",
          "label" => true,
          "i18n_template" => "incfreq",
        },
        {
          "key" => "field_formatted_as_currency",
          "arguments_for_key" => "earnings",
          "i18n_template" => "earnings",
        },
      ],
    }

    @informative_text = {
      "translation" => "soft_validations.net_income.hint_text",
      "arguments" => [
        {
          "key" => "net_income_higher_or_lower_text",
          "label" => false,
          "i18n_template" => "net_income_higher_or_lower_text",
        },
      ],
    }
  end

  def questions
    @questions ||= [Form::Lettings::Questions::NetIncomeValueCheck.new(nil, nil, self)]
  end

  def interruption_screen_question_ids
    %w[incfreq earnings hhmemb ecstat1 ecstat2 ecstat3 ecstat4 ecstat5 ecstat6 ecstat7 ecstat8]
  end
end
