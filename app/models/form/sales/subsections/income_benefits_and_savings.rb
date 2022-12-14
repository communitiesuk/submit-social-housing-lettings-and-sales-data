class Form::Sales::Subsections::IncomeBenefitsAndSavings < ::Form::Subsection
  def initialize(id, hsh, section)
    super
    @id = "income_benefits_and_savings"
    @label = "Income, benefits and savings"
    @section = section
    @depends_on = [{ "setup_completed?" => true }]
  end

  def pages
    @pages ||= [
      Form::Sales::Pages::Buyer1Income.new(nil, nil, self),
      Form::Sales::Pages::Buyer1IncomeValueCheck.new(nil, nil, self),
      Form::Sales::Pages::MortgageValueCheck.new(nil, nil, self, { id_prefix: "buyer_1_income_" }),
      Form::Sales::Pages::Buyer1Mortgage.new(nil, nil, self),
      Form::Sales::Pages::MortgageValueCheck.new(nil, nil, self, { id_prefix: "buyer_1_" }),
      Form::Sales::Pages::Buyer2Income.new(nil, nil, self),
      Form::Sales::Pages::MortgageValueCheck.new(nil, nil, self, { id_prefix: "buyer_2_income_" }),
      Form::Sales::Pages::Savings.new(nil, nil, self),
      Form::Sales::Pages::PreviousOwnership.new(nil, nil, self),
    ]
  end
end
