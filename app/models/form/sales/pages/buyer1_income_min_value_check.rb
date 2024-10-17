class Form::Sales::Pages::Buyer1IncomeMinValueCheck < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @depends_on = [
      {
        "income1_under_soft_min?" => true,
      },
    ]
    @copy_key = "sales.soft_validations.income1_value_check.min"
    @title_text = {
      "translation" => "forms.#{form.start_date.year}.#{@copy_key}.title_text",
      "arguments" => [
        {
          "key" => "field_formatted_as_currency",
          "arguments_for_key" => "income1",
          "i18n_template" => "income",
        },
        {
          "key" => "income_soft_min_for_ecstat",
          "arguments_for_key" => "ecstat1",
          "i18n_template" => "minimum",
        },
      ],
    }
    @informative_text = {
      "translation" => "forms.#{form.start_date.year}.#{@copy_key}.informative_text",
      "arguments" => [],
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
