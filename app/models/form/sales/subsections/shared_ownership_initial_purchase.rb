class Form::Sales::Subsections::SharedOwnershipInitialPurchase < ::Form::Subsection
  def initialize(id, hsh, section)
    super
    @id = "shared_ownership_initial_purchase"
    @label = "Shared ownership - initial purchase"
    @depends_on = [{ "ownershipsch" => 1, "setup_completed?" => true, "staircase" => 2 }]
    @copy_key = "sale_information"
  end

  def pages
    @pages ||= [
      Form::Sales::Pages::Resale.new(nil, nil, self),
      Form::Sales::Pages::LivingBeforePurchase.new("living_before_purchase_shared_ownership_joint_purchase", nil, self, ownershipsch: 1, joint_purchase: true),
      Form::Sales::Pages::LivingBeforePurchase.new("living_before_purchase_shared_ownership", nil, self, ownershipsch: 1, joint_purchase: false),
      Form::Sales::Pages::HandoverDate.new(nil, nil, self),
      Form::Sales::Pages::HandoverDateCheck.new(nil, nil, self),
      Form::Sales::Pages::BuyerPrevious.new("buyer_previous_joint_purchase", nil, self, joint_purchase: true),
      Form::Sales::Pages::BuyerPrevious.new("buyer_previous_not_joint_purchase", nil, self, joint_purchase: false),
      Form::Sales::Pages::PreviousBedrooms.new(nil, nil, self),
      Form::Sales::Pages::PreviousPropertyType.new(nil, nil, self),
      Form::Sales::Pages::PreviousTenure.new(nil, nil, self),
      Form::Sales::Pages::ValueSharedOwnership.new("value_shared_ownership", nil, self),
      Form::Sales::Pages::AboutPriceValueCheck.new("about_price_shared_ownership_value_check", nil, self),
      Form::Sales::Pages::Equity.new("initial_equity", nil, self),
      Form::Sales::Pages::SharedOwnershipDepositValueCheck.new("shared_ownership_equity_value_check", nil, self),
      Form::Sales::Pages::Mortgageused.new("mortgage_used_shared_ownership", nil, self, ownershipsch: 1),
      Form::Sales::Pages::MortgageValueCheck.new("mortgage_used_mortgage_value_check", nil, self),
      Form::Sales::Pages::MortgageAmount.new("mortgage_amount_shared_ownership", nil, self, ownershipsch: 1),
      Form::Sales::Pages::SharedOwnershipDepositValueCheck.new("shared_ownership_mortgage_amount_value_check", nil, self),
      Form::Sales::Pages::MortgageValueCheck.new("mortgage_amount_mortgage_value_check", nil, self),
      Form::Sales::Pages::MortgageLength.new("mortgage_length_shared_ownership", nil, self, ownershipsch: 1),
      Form::Sales::Pages::Deposit.new("deposit_shared_ownership", nil, self, ownershipsch: 1, optional: false),
      Form::Sales::Pages::Deposit.new("deposit_shared_ownership_optional", nil, self, ownershipsch: 1, optional: true),
      Form::Sales::Pages::DepositValueCheck.new("deposit_joint_purchase_value_check", nil, self, joint_purchase: true),
      Form::Sales::Pages::DepositValueCheck.new("deposit_value_check", nil, self, joint_purchase: false),
      Form::Sales::Pages::DepositDiscount.new("deposit_discount", nil, self, optional: false),
      Form::Sales::Pages::DepositDiscount.new("deposit_discount_optional", nil, self, optional: true),
      Form::Sales::Pages::SharedOwnershipDepositValueCheck.new("shared_ownership_deposit_value_check", nil, self),
      Form::Sales::Pages::MonthlyRent.new(nil, nil, self),
      Form::Sales::Pages::ServiceCharge.new("service_charges_shared_ownership", nil, self, ownershipsch: 1),
      Form::Sales::Pages::MonthlyChargesValueCheck.new("monthly_charges_shared_ownership_value_check", nil, self, ownershipsch: 1),
      Form::Sales::Pages::EstateManagementFee.new("estate_management_fee", nil, self),
    ].compact
  end

  def displayed_in_tasklist?(log)
    log.staircase == 2 && (log.ownershipsch.nil? || log.ownershipsch == 1)
  end
end
