class Form::Sales::Pages::Deposit < ::Form::Page
  def initialize(id, hsh, subsection, ownershipsch:, optional:)
    super(id, hsh, subsection)
    @ownershipsch = ownershipsch
    @optional = optional
    @copy_key = "sales.sale_information.deposit"
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::DepositAmount.new(nil, nil, self, ownershipsch: @ownershipsch, optional: @optional),
    ]
  end

  def routed_to?(log, _user)
    return false unless super
    return true if log.ownershipsch == 2 || (log.ownershipsch == 3 && log.mortgageused == 1)
    return false if log.stairowned_100? != @optional && form.start_year_after_2024?

    log.ownershipsch == 1
  end
end
