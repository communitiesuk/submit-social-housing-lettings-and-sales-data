class Form::Sales::Subsections::OutrightSale < ::Form::Subsection
  def initialize(id, hsh, section)
    super
    @id = "outright_sale"
    @label = "Outright sale"
    @depends_on = [{ "ownershipsch" => 3, "setup_completed?" => true }]
    @copy_key = "sale_information"
  end

  def pages
    @pages ||= [
      Form::Sales::Pages::PurchasePriceOutrightOwnership.new("purchase_price_outright_sale", nil, self, ownershipsch: 3),
      Form::Sales::Pages::AboutPriceValueCheck.new("about_price_outright_sale_value_check", nil, self),
      Form::Sales::Pages::Mortgageused.new("mortgage_used_outright_sale", nil, self, ownershipsch: 3),
      Form::Sales::Pages::MortgageValueCheck.new("outright_sale_mortgage_used_mortgage_value_check", nil, self),
      Form::Sales::Pages::MortgageAmount.new("mortgage_amount_outright_sale", nil, self, ownershipsch: 3),
      Form::Sales::Pages::MortgageValueCheck.new("outright_sale_mortgage_amount_mortgage_value_check", nil, self),
      (Form::Sales::Pages::MortgageLender.new("mortgage_lender_outright_sale", nil, self, ownershipsch: 3) unless form.start_year_2024_or_later?),
      (Form::Sales::Pages::MortgageLenderOther.new("mortgage_lender_other_outright_sale", nil, self, ownershipsch: 3) unless form.start_year_2024_or_later?),
      Form::Sales::Pages::MortgageLength.new("mortgage_length_outright_sale", nil, self, ownershipsch: 3),
      Form::Sales::Pages::ExtraBorrowing.new("extra_borrowing_outright_sale", nil, self, ownershipsch: 3),
      Form::Sales::Pages::Deposit.new("deposit_outright_sale", nil, self, ownershipsch: 3, optional: false),
      Form::Sales::Pages::DepositValueCheck.new("outright_sale_deposit_joint_purchase_value_check", nil, self, joint_purchase: true),
      Form::Sales::Pages::DepositValueCheck.new("outright_sale_deposit_value_check", nil, self, joint_purchase: false),
      leasehold_charge_pages,
      Form::Sales::Pages::MonthlyChargesValueCheck.new("monthly_charges_outright_sale_value_check", nil, self),
    ].flatten.compact
  end

  def displayed_in_tasklist?(log)
    log.ownershipsch.nil? || log.ownershipsch == 3
  end

  def leasehold_charge_pages
    if form.start_date.year >= 2023
      Form::Sales::Pages::LeaseholdCharges.new("leasehold_charges_outright_sale", nil, self, ownershipsch: 3)
    end
  end
end
