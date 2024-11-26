class Form::Sales::Subsections::SharedOwnershipStaircasingTransaction < ::Form::Subsection
  def initialize(id, hsh, section)
    super
    @id = "shared_ownership_staircasing_transaction"
    @label = "Shared ownership - staircasing transaction"
    @depends_on = [{ "ownershipsch" => 1, "setup_completed?" => true, "staircase" => 1 }]
    @copy_key = "sale_information"
  end

  def pages
    @pages ||= [
      Form::Sales::Pages::AboutStaircase.new("about_staircasing_joint_purchase", nil, self, joint_purchase: true),
      Form::Sales::Pages::AboutStaircase.new("about_staircasing_not_joint_purchase", nil, self, joint_purchase: false),
      Form::Sales::Pages::StaircaseSale.new(nil, nil, self),
      Form::Sales::Pages::StaircaseBoughtValueCheck.new(nil, nil, self),
      Form::Sales::Pages::StaircaseOwnedValueCheck.new("staircase_owned_value_check_joint_purchase", nil, self, joint_purchase: true),
      Form::Sales::Pages::StaircaseOwnedValueCheck.new("staircase_owned_value_check_not_joint_purchase", nil, self, joint_purchase: false),
      Form::Sales::Pages::StaircaseFirstTime.new(nil, nil, self),
      Form::Sales::Pages::StaircasePrevious.new(nil, nil, self),
      Form::Sales::Pages::StaircaseInitialDate.new(nil, nil, self),
      Form::Sales::Pages::ValueSharedOwnership.new("value_shared_ownership_staircase", nil, self),
      Form::Sales::Pages::AboutPriceValueCheck.new("about_price_shared_ownership_value_check", nil, self),
      Form::Sales::Pages::Equity.new("staircase_equity", nil, self),
      Form::Sales::Pages::SharedOwnershipDepositValueCheck.new("shared_ownership_equity_value_check", nil, self),
      Form::Sales::Pages::Mortgageused.new("staircase_mortgage_used_shared_ownership", nil, self, ownershipsch: 1),
      Form::Sales::Pages::MonthlyRentStaircasingOwned.new(nil, nil, self),
      Form::Sales::Pages::MonthlyRentStaircasing.new(nil, nil, self),
      Form::Sales::Pages::MonthlyChargesValueCheck.new("monthly_charges_shared_ownership_value_check", nil, self),
    ].compact
  end

  def displayed_in_tasklist?(log)
    log.staircase == 1 && (log.ownershipsch.nil? || log.ownershipsch == 1)
  end
end
