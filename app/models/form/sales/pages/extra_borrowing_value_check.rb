class Form::Sales::Pages::ExtraBorrowingValueCheck < Form::Page
  def initialize(id, hsh, subsection)
    super
    @depends_on = [
      {
        "extra_borrowing_expected_but_not_reported?" => true,
      },
    ]
    @title_text = {
      "translation" => "soft_validations.extra_borrowing.title_text",
      "arguments" => [
        {
          "key" => "field_formatted_as_currency",
          "arguments_for_key" => "mortgage_and_deposit_total",
          "i18n_template" => "mortgage_and_deposit_total",
        },
      ],
    }
    @informative_text = {
      "translation" => "soft_validations.extra_borrowing.hint_text",
      "arguments" => [],
    }
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::ExtraBorrowingValueCheck.new(nil, nil, self),
    ]
  end

  def interruption_screen_question_ids
    %w[extrabor mortgage deposit value discount]
  end
end
