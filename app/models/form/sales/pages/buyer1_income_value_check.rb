class Form::Sales::Pages::Buyer1IncomeValueCheck < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @depends_on = [
      {
        "income1_under_soft_min?" => true,
      },
    ]
    @title_text = {
      "translation" => "soft_validations.net_income.below_soft_min",
      "arguments" => [
        {
          "key" => "income1",
          "label" => true,
          "i18n_template" => "income1",
        },
        {
          "key" => "allowed_income_soft_min",
          "label" => false,
          "i18n_template" => "soft_min",
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
