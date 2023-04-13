class Form::Sales::Pages::Buyer2IncomeMaxValueCheck < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @depends_on = [
      {
        "income2_over_soft_max?" => true,
      },
    ]
    @title_text = {
      "translation" => "soft_validations.income.over_soft_max_for_la_buyer_2",
      "arguments" => [
        {
          "key" => "field_formatted_as_currency",
          "arguments_for_key" => "income2",
          "i18n_template" => "income",
        },
      ],
    }
    @informative_text = {}
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::Buyer2IncomeValueCheck.new(nil, nil, self),
    ]
  end
end
