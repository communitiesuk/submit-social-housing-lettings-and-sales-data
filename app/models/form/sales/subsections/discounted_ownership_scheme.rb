class Form::Sales::Subsections::DiscountedOwnershipScheme < ::Form::Subsection
  def initialize(id, hsh, section)
    super
    @id = "discounted_ownership_scheme"
    @label = "Discounted ownership scheme"
    @section = section
    @depends_on = [{ "ownershipsch" => 2, "setup_completed?" => true }]
  end

  def pages
    @pages ||= [
      Form::Sales::Pages::LivingBeforePurchase.new("living_before_purchase_discounted_ownership", nil, self),
      Form::Sales::Pages::AboutPriceRtb.new(nil, nil, self),
      Form::Sales::Pages::AboutPriceNotRtb.new(nil, nil, self),
      Form::Sales::Pages::MortgageAmount.new("mortgage_amount_discounted_ownership", nil, self),
      Form::Sales::Pages::AboutDeposit.new("about_deposit_discounted_ownership", nil, self),
    ]
  end

  def displayed_in_tasklist?(log)
    log.ownershipsch == 2
  end
end
