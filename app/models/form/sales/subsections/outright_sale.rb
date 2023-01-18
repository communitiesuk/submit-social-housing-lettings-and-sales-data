class Form::Sales::Subsections::OutrightSale < ::Form::Subsection
  def initialize(id, hsh, section)
    super
    @id = "outright_sale"
    @label = "Outright sale"
    @depends_on = [{ "ownershipsch" => 3, "setup_completed?" => true }]
  end

  def pages
    @pages ||= [
      Form::Sales::Pages::PurchasePrice.new("purchase_price_outright_sale", nil, self),
      Form::Sales::Pages::Mortgageused.new("mortgage_used_outright_sale", nil, self),
      Form::Sales::Pages::MortgageAmount.new("mortgage_amount_outright_sale", nil, self),
      Form::Sales::Pages::MortgageLender.new("mortgage_lender_outright_sale", nil, self),
      Form::Sales::Pages::MortgageLenderOther.new("mortgage_lender_other_outright_sale", nil, self),
      Form::Sales::Pages::MortgageLength.new("mortgage_length_outright_sale", nil, self),
      Form::Sales::Pages::ExtraBorrowing.new("extra_borrowing_outright_sale", nil, self),
      Form::Sales::Pages::ExtraBorrowingValueCheck.new("extra_borrowing_value_check_outright_sale", nil, self),
      Form::Sales::Pages::AboutDepositWithoutDiscount.new("about_deposit_outright_sale", nil, self),
      Form::Sales::Pages::DepositValueCheck.new("outright_sale_deposit_value_check", nil, self),
      Form::Sales::Pages::LeaseholdCharges.new("leasehold_charges_outright_sale", nil, self),
    ]
  end

  def displayed_in_tasklist?(log)
    log.ownershipsch == 3
  end
end
