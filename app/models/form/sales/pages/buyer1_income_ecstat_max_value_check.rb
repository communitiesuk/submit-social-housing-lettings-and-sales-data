class Form::Sales::Pages::Buyer1IncomeEcstatMaxValueCheck < ::Form::Page
  def initialize(id, hsh, subsection, check_answers_card_number:)
    super(id, hsh, subsection)
    @depends_on = [
      {
        "income1_over_soft_max_for_ecstat?" => true,
      },
    ]
    @copy_key = "sales.soft_validations.income1_value_check.max.ecstat"
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
    @informative_text = {}
    @check_answers_card_number = check_answers_card_number
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::Buyer1IncomeValueCheck.new(nil, nil, self, check_answers_card_number: @check_answers_card_number),
    ]
  end

  def interruption_screen_question_ids
    %w[ecstat1 income1]
  end
end
