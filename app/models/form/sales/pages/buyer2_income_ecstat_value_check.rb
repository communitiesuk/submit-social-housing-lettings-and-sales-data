class Form::Sales::Pages::Buyer2IncomeEcstatValueCheck < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @depends_on = [
      {
        "income2_out_of_soft_range?" => true,
      },
    ]
    @copy_key = "sales.soft_validations.income2_value_check.ecstat"
    @title_text = {
      "translation" => "forms.#{form.start_date.year}.#{@copy_key}.title_text",
      "arguments" => [
        {
          "key" => "field_formatted_as_currency",
          "arguments_for_key" => "income2",
          "i18n_template" => "income",
        },
      ],
    }
    @informative_text = {
      "translation" => "forms.#{form.start_date.year}.#{@copy_key}.informative_text",
      "arguments" => [
        {
          "key" => "income2_more_or_less_text",
          "i18n_template" => "more_or_less",
        },
      ],
    }
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::Buyer2IncomeValueCheck.new(nil, nil, self, check_answers_card_number: 2),
    ]
  end

  def interruption_screen_question_ids
    %w[ecstat2 income2]
  end
end
