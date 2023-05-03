class Form::Sales::Pages::DepositValueCheck < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @depends_on = [
      {
        "deposit_over_soft_max?" => true,
      },
    ]
    @informative_text = {
      "translation" => "soft_validations.deposit.hint_text",
      "arguments" => [],
    }
    @title_text = {
      "translation" => "soft_validations.deposit.title_text",
      "arguments" => [
        {
          "key" => "field_formatted_as_currency",
          "arguments_for_key" => "deposit",
          "i18n_template" => "deposit",
        },
        {
          "key" => "field_formatted_as_currency",
          "arguments_for_key" => "savings",
          "i18n_template" => "savings",
        },
      ],
    }
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::DepositValueCheck.new(nil, nil, self),
    ]
  end

  def interruption_screen_question_ids
    %w[savings deposit]
  end
end
