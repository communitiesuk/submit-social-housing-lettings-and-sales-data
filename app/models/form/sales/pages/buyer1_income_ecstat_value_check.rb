class Form::Sales::Pages::Buyer1IncomeEcstatValueCheck < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @depends_on = [
      {
        "income1_outside_soft_range_for_ecstat?" => true,
      },
    ]
    @copy_key = "sales.soft_validations.income1_value_check.ecstat"
    @title_text = {
      "translation" => "forms.#{form.start_date.year}.#{@copy_key}.title_text",
      "arguments" => [
        {
          "key" => "field_formatted_as_currency",
          "arguments_for_key" => "income1",
          "i18n_template" => "income",
        },
      ],
    }
    @informative_text = {
      "translation" => "forms.#{form.start_date.year}.#{@copy_key}.informative_text",
      "arguments" => [
        {
          "key" => "income1_more_or_less_text",
          "i18n_template" => "more_or_less",
        },
      ],
    }
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::Buyer1IncomeValueCheck.new(nil, nil, self, check_answers_card_number: 1),
    ]
  end

  def interruption_screen_question_ids
    %w[ecstat1 income1]
  end
end
