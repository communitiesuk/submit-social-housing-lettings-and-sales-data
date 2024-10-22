class Form::Sales::Pages::Buyer1IncomeMaxValueCheck < ::Form::Page
  def initialize(id, hsh, subsection, check_answers_card_number:)
    super(id, hsh, subsection)
    @depends_on = [
      {
        "income1_over_soft_max?" => true,
      },
    ]
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
    %w[uprn postcode_full la income1]
  end
end
