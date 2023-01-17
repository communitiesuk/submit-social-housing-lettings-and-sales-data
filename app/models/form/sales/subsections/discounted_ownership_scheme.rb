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
      Form::Sales::Pages::AboutPriceNotRtb.new(nil, nil, self),
      Form::Sales::Pages::Mortgageused.new("mortgage_used_discounted_ownership", nil, self),
      Form::Sales::Pages::MortgageAmount.new("mortgage_amount_discounted_ownership", nil, self),
      Form::Sales::Pages::MortgageLender.new("mortgage_lender_discounted_ownership", nil, self),
      Form::Sales::Pages::MortgageLenderOther.new("mortgage_lender_other_discounted_ownership", nil, self),
      Form::Sales::Pages::MortgageLength.new("mortgage_length_discounted_ownership", nil, self),
      Form::Sales::Pages::ExtraBorrowing.new("extra_borrowing_discounted_ownership", nil, self),
      Form::Sales::Pages::AboutDepositWithoutDiscount.new("about_deposit_discounted_ownership", nil, self),
      Form::Sales::Pages::DepositValueCheck.new("discounted_ownership_deposit_value_check", nil, self),
      Form::Sales::Pages::LeaseholdCharges.new("leasehold_charges_discounted_ownership", nil, self),
    ]
  end

  def displayed_in_tasklist?(log)
    log.ownershipsch == 2
  end
end
