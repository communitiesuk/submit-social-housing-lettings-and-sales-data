class Form::Sales::Subsections::DiscountedOwnershipScheme < ::Form::Subsection
  def initialize(id, hsh, section)
    super
    @id = "discounted_ownership_scheme"
    @label = "Discounted ownership scheme"
    @depends_on = [{ "ownershipsch" => 2, "setup_completed?" => true }]
    @copy_key = "sale_information"
  end

  def pages
    @pages ||= [
      Form::Sales::Pages::LivingBeforePurchase.new("living_before_purchase_discounted_ownership_joint_purchase", nil, self, ownershipsch: 2, joint_purchase: true),
      Form::Sales::Pages::LivingBeforePurchase.new("living_before_purchase_discounted_ownership", nil, self, ownershipsch: 2, joint_purchase: false),
      Form::Sales::Pages::PurchasePrice.new(nil, nil, self),
      Form::Sales::Pages::Discount.new(nil, nil, self),
      Form::Sales::Pages::ExtraBorrowingValueCheck.new("extra_borrowing_price_value_check", nil, self),
      Form::Sales::Pages::PercentageDiscountValueCheck.new("percentage_discount_value_check", nil, self),
      Form::Sales::Pages::Grant.new(nil, nil, self),
      Form::Sales::Pages::GrantValueCheck.new(nil, nil, self),
      Form::Sales::Pages::PurchasePriceOutrightOwnership.new("purchase_price_discounted_ownership", nil, self, ownershipsch: 2),
      Form::Sales::Pages::DiscountedSaleValueCheck.new("discounted_sale_grant_value_check", nil, self),
      Form::Sales::Pages::AboutPriceValueCheck.new("about_price_discounted_ownership_value_check", nil, self),
      Form::Sales::Pages::DepositAndMortgageValueCheck.new("discounted_ownership_deposit_and_mortgage_value_check_after_value_and_discount", nil, self),
      Form::Sales::Pages::Mortgageused.new("mortgage_used_discounted_ownership", nil, self, ownershipsch: 2),
      Form::Sales::Pages::MortgageValueCheck.new("discounted_ownership_mortgage_used_mortgage_value_check", nil, self),
      Form::Sales::Pages::DiscountedSaleValueCheck.new("discounted_sale_mortgage_used_value_check", nil, self),
      Form::Sales::Pages::MortgageAmount.new("mortgage_amount_discounted_ownership", nil, self, ownershipsch: 2),
      Form::Sales::Pages::MortgageValueCheck.new("discounted_ownership_mortgage_amount_mortgage_value_check", nil, self),
      Form::Sales::Pages::DiscountedSaleValueCheck.new("discounted_sale_mortgage_value_check", nil, self),
      Form::Sales::Pages::ExtraBorrowingValueCheck.new("extra_borrowing_mortgage_value_check", nil, self),
      Form::Sales::Pages::DepositAndMortgageValueCheck.new("discounted_ownership_deposit_and_mortgage_value_check_after_mortgage", nil, self),
      mortgage_lender_questions,
      Form::Sales::Pages::MortgageLength.new("mortgage_length_discounted_ownership", nil, self, ownershipsch: 2),
      Form::Sales::Pages::ExtraBorrowing.new("extra_borrowing_discounted_ownership", nil, self, ownershipsch: 2),
      Form::Sales::Pages::ExtraBorrowingValueCheck.new("extra_borrowing_value_check", nil, self),
      Form::Sales::Pages::Deposit.new("deposit_discounted_ownership", nil, self, ownershipsch: 2, optional: false),
      Form::Sales::Pages::ExtraBorrowingValueCheck.new("extra_borrowing_deposit_value_check", nil, self),
      Form::Sales::Pages::DepositValueCheck.new("discounted_ownership_deposit_joint_purchase_value_check", nil, self, joint_purchase: true),
      Form::Sales::Pages::DepositValueCheck.new("discounted_ownership_deposit_value_check", nil, self, joint_purchase: false),
      Form::Sales::Pages::DepositAndMortgageValueCheck.new("discounted_ownership_deposit_and_mortgage_value_check_after_deposit", nil, self),
      Form::Sales::Pages::DiscountedSaleValueCheck.new("discounted_sale_deposit_value_check", nil, self),
      Form::Sales::Pages::LeaseholdCharges.new("leasehold_charges_discounted_ownership", nil, self, ownershipsch: 2),
      Form::Sales::Pages::MonthlyChargesValueCheck.new("monthly_charges_discounted_ownership_value_check", nil, self),
    ].flatten.compact
  end

  def displayed_in_tasklist?(log)
    log.ownershipsch.nil? || log.ownershipsch == 2
  end

  def mortgage_lender_questions
    unless form.start_year_2025_or_later?
      [
        Form::Sales::Pages::MortgageLender.new("mortgage_lender_discounted_ownership", nil, self, ownershipsch: 2),
        Form::Sales::Pages::MortgageLenderOther.new("mortgage_lender_other_discounted_ownership", nil, self, ownershipsch: 2),
      ]
    end
  end
end
