class Form::Sales::Pages::Deposit < ::Form::Page
  def initialize(id, hsh, subsection, ownershipsch:, optional:)
    super(id, hsh, subsection)
    @ownershipsch = ownershipsch
    @optional = optional
    @copy_key = copy_key
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::DepositAmount.new(nil, nil, self, ownershipsch: @ownershipsch, optional: @optional),
    ]
  end

  def routed_to?(log, _user)
    return false unless super
    return true if log.ownershipsch == 2 || (log.ownershipsch == 3 && log.mortgageused == 1)
    return false if log.stairowned_100? != @optional && form.start_year_2024_or_later?

    log.ownershipsch == 1
  end

  def copy_key
    return "sales.sale_information.deposit.shared_ownership" if @ownershipsch == 1
    return "sales.sale_information.deposit.discounted_ownership" if @ownershipsch == 2
    return "sales.sale_information.deposit.outright_sale" if @ownershipsch == 3
  end
end
