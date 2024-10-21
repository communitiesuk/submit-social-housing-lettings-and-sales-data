class Form::Sales::Pages::DepositAndMortgageValueCheck < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @depends_on = [
      {
        "mortgage_plus_deposit_less_than_discounted_value?" => true,
      },
    ]
    @copy_key = "sales.sale_information.deposit_and_mortgage_value_check"
    @title_text = {
      "translation" => "forms.#{form.start_date.year}.#{@copy_key}.title_text",
      "arguments" => [
        {
          "key" => "mortgage",
          "label" => true,
          "i18n_template" => "mortgage",
        },
        {
          "key" => "deposit",
          "label" => true,
          "i18n_template" => "deposit",
        },
        {
          "key" => "discount",
          "label" => true,
          "i18n_template" => "discount",
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
      Form::Sales::Questions::DepositAndMortgageValueCheck.new(nil, nil, self),
    ]
  end

  def interruption_screen_question_ids
    %w[mortgage deposit value discount]
  end
end
