class Form::Sales::Pages::AboutDeposit < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @header = "About the deposit"
    @description = ""
    @subsection = subsection
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::DepositAmount.new(nil, nil, self),
      Form::Sales::Questions::DepositDiscount.new(nil, nil, self),
    ]
  end
end
