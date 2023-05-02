class Form::Sales::Pages::SavingsValueCheck < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @depends_on = [
      {
        "savings_over_soft_max?" => true,
      },
    ]
    @title_text = {
      "translation" => "soft_validations.savings.title_text",
      "arguments" => [
        {
          "key" => "field_formatted_as_currency",
          "arguments_for_key" => "savings",
          "i18n_template" => "savings",
        },
      ],
    }
    @informative_text = {
      "translation" => "soft_validations.savings.hint_text",
      "arguments" => [],
    }
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::SavingsValueCheck.new(nil, nil, self),
    ]
  end

  def interruption_screen_question_ids
    %w[savings]
  end
end
