class Form::Sales::Pages::CombinedIncomeMaxValueCheck < ::Form::Page
  def initialize(id, hsh, subsection, check_answers_card_number:)
    super(id, hsh, subsection)
    @depends_on = [
      {
        "combined_income_over_soft_max?" => true,
      },
    ]
    @copy_key = "sales.soft_validations.combined_income_value_check"
    @title_text = {
      "translation" => "forms.#{form.start_date.year}.#{@copy_key}.title_text",
      "arguments" => [
        {
          "key" => "field_formatted_as_currency",
          "arguments_for_key" => "combined_income",
          "i18n_template" => "combined_income",
        },
      ],
    }
    @informative_text = {}
    @check_answers_card_number = check_answers_card_number
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::CombinedIncomeValueCheck.new(nil, nil, self, check_answers_card_number: @check_answers_card_number),
    ]
  end

  def interruption_screen_question_ids
    %w[uprn postcode_full la income1 income2]
  end
end
