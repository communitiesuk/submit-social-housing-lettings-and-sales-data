class Form::Sales::Pages::Buyer2IncomeMaxValueCheck < ::Form::Page
  def initialize(id, hsh, subsection, check_answers_card_number:)
    super(id, hsh, subsection)
    @depends_on = [
      {
        "income2_over_soft_max?" => true,
      },
    ]
    @copy_key = "sales.soft_validations.income2_value_check.max"
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
    @informative_text = {}
    @check_answers_card_number = check_answers_card_number
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::Buyer2IncomeValueCheck.new(nil, nil, self, check_answers_card_number: @check_answers_card_number),
    ]
  end

  def interruption_screen_question_ids
    %w[uprn postcode_full la income2]
  end
end
