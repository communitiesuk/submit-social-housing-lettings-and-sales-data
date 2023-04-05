class Form::Sales::Pages::CombinedIncomeMaxValueCheck < ::Form::Page
  def initialize(id, hsh, subsection, buyer_index:)
    super(id, hsh, subsection)
    @depends_on = [
      {
        "combined_income_over_soft_max?" => true,
      },
    ]
    @title_text = {
      "translation" => "soft_validations.income.over_soft_max_for_la_combined",
      "arguments" => [
        {
          "key" => "field_formatted_as_currency",
          "arguments_for_key" => "combined_income",
          "i18n_template" => "combined_income",
        }
      ],
    }
    @informative_text = {}
    @buyer_index = buyer_index
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::CombinedIncomeValueCheck.new(nil, nil, self, buyer_index: @buyer_index),
    ]
  end
end
