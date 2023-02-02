class Form::Sales::Subsections::DiscountedOwnershipScheme < ::Form::Subsection
  def initialize(id, hsh, section)
    super
    @id = "discounted_ownership_scheme"
    @label = "Discounted ownership scheme"
    @depends_on = [{ "ownershipsch" => 2, "setup_completed?" => true }]
  end

  def pages
    @pages ||= [
      Form::Sales::Pages::LivingBeforePurchase.new("living_before_purchase_discounted_ownership", nil, self),
      Form::Sales::Pages::AboutPriceRtb.new(nil, nil, self),
      Form::Sales::Pages::ExtraBorrowingValueCheck.new("extra_borrowing_price_value_check", nil, self),
      Form::Sales::Pages::AboutPriceNotRtb.new(nil, nil, self),
      Form::Sales::Pages::GrantValueCheck.new(nil, nil, self),
      Form::Sales::Pages::PurchasePrice.new("purchase_price_discounted_ownership", nil, self),
      Form::Sales::Pages::DepositAndMortgageValueCheck.new("discounted_ownership_deposit_and_mortgage_value_check_after_value_and_discount", nil, self),
      Form::Sales::Pages::Mortgageused.new("mortgage_used_discounted_ownership", nil, self),
      Form::Sales::Pages::MortgageValueCheck.new("discounted_ownership_mortgage_used_mortgage_value_check", nil, self),
      Form::Sales::Pages::MortgageAmount.new("mortgage_amount_discounted_ownership", nil, self),
      Form::Sales::Pages::MortgageValueCheck.new("discounted_ownership_mortgage_amount_mortgage_value_check", nil, self),
      Form::Sales::Pages::ExtraBorrowingValueCheck.new("extra_borrowing_mortgage_value_check", nil, self),
      Form::Sales::Pages::DepositAndMortgageValueCheck.new("discounted_ownership_deposit_and_mortgage_value_check_after_mortgage", nil, self),
      Form::Sales::Pages::MortgageLender.new("mortgage_lender_discounted_ownership", nil, self),
      Form::Sales::Pages::MortgageLenderOther.new("mortgage_lender_other_discounted_ownership", nil, self),
      Form::Sales::Pages::MortgageLength.new("mortgage_length_discounted_ownership", nil, self),
      Form::Sales::Pages::ExtraBorrowing.new("extra_borrowing_discounted_ownership", nil, self),
      Form::Sales::Pages::ExtraBorrowingValueCheck.new("extra_borrowing_value_check", nil, self),
      Form::Sales::Pages::AboutDepositWithoutDiscount.new("about_deposit_discounted_ownership", nil, self),
      Form::Sales::Pages::ExtraBorrowingValueCheck.new("extra_borrowing_deposit_value_check", nil, self),
      Form::Sales::Pages::DepositValueCheck.new("discounted_ownership_deposit_value_check", nil, self),
      Form::Sales::Pages::DepositAndMortgageValueCheck.new("discounted_ownership_deposit_and_mortgage_value_check_after_deposit", nil, self),
      Form::Sales::Pages::LeaseholdCharges.new("leasehold_charges_discounted_ownership", nil, self),
      Form::Sales::Pages::MonthlyChargesValueCheck.new("monthly_charges_discounted_ownership_value_check", nil, self),
    ]
  end

  def displayed_in_tasklist?(log)
    log.ownershipsch == 2
  end
end
