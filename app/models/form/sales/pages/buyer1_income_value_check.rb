class Form::Sales::Pages::Buyer1IncomeValueCheck < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @depends_on = [
      {
        "income1_under_soft_min?" => true,
      },
    ]
    @title_text = {
      "translation" => "soft_validations.income.under_soft_min_for_economic_status",
      "arguments" => [
        {
          "key" => "field_formatted_as_currency",
          "arguments_for_public_send" => "income1",
          "i18n_template" => "income",
        },
        {
          "key" => "income_soft_min_for_ecstat",
          "arguments_for_public_send" => "ecstat1",
          "i18n_template" => "minimum",
        },
      ],
    }
    @informative_text = {}
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::Buyer1IncomeValueCheck.new(nil, nil, self),
    ]
  end
end
