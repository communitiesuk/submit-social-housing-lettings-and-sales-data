class Form::Sales::Pages::DepositAndMortgageValueCheck < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @depends_on = [
      {
        "mortgage_plus_deposit_less_than_discounted_value?" => true,
      },
    ]
    @informative_text = {}
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::DepositAndMortgageValueCheck.new(nil, nil, self),
    ]
  end
end
