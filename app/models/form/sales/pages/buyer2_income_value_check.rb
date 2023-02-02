class Form::Sales::Pages::Buyer2IncomeValueCheck < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @header = ""
    @description = ""
    @subsection = subsection
    @depends_on = [
      {
        "income2_under_soft_min?" => true,
      },
    ]
    @title_text = {
      "translation" => "soft_validations.income.under_soft_min_for_economic_status",
      "arguments" => [
        {
          "key" => "income2",
          "i18n_template" => "income",
        },
        {
          "key" => "income_soft_min_for_ecstat",
          "arguments_for_public_send" => "ecstat2",
          "i18n_template" => "minimum",
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
