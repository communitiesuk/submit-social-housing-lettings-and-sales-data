module Validations::Sales::SoftValidations
  ALLOWED_INCOME_RANGES = {
    1 => OpenStruct.new(soft_min: 5000),
    2 => OpenStruct.new(soft_min: 1500),
    3 => OpenStruct.new(soft_min: 1000),
    5 => OpenStruct.new(soft_min: 2000),
    0 => OpenStruct.new(soft_min: 2000),
  }.freeze

  def income1_under_soft_min?
    return false unless ecstat1 && income1 && ALLOWED_INCOME_RANGES[ecstat1]

    income1 < ALLOWED_INCOME_RANGES[ecstat1][:soft_min]
  end

  def staircase_bought_above_fifty?
    stairbought && stairbought > 50
  end

  def income2_under_soft_min?
    return false unless ecstat2 && income2 && ALLOWED_INCOME_RANGES[ecstat2]

    income2 < ALLOWED_INCOME_RANGES[ecstat2][:soft_min]
  end

  def mortgage_over_soft_max?
    return false unless mortgage && inc1mort && (inc2mort || not_joint_purchase?)
    return false if income1_used_for_mortgage? && income1.blank? || income2_used_for_mortgage? && income2.blank?

    income_used_for_mortgage = (income1_used_for_mortgage? ? income1 : 0) + (income2_used_for_mortgage? ? income2 : 0)
    mortgage > income_used_for_mortgage * 5
  end

  def wheelchair_when_not_disabled?
    return unless disabled && wheel

    wheel == 1 && disabled == 2
  end

  def savings_over_soft_max?
    savings && savings > 100_000
  end

  def deposit_over_soft_max?
    return unless savings && deposit

    deposit > savings * 4 / 3
  end

  def extra_borrowing_expected_but_not_reported?
    return unless extrabor && mortgage && deposit && value && discount

    extrabor != 1 && mortgage + deposit > value - value * discount / 100
  end

  def purchase_price_out_of_soft_range?
    return unless value && beds && la && sale_range

    !value.between?(sale_range.soft_min, sale_range.soft_max)
  end

  def shared_ownership_deposit_invalid?
    return unless mortgage || mortgageused == 2
    return unless cashdis || !is_type_discount?
    return unless deposit && value && equity

    cash_discount = cashdis || 0
    mortgage_value = mortgage || 0
    mortgage_value + deposit + cash_discount != value * equity / 100
  end

  def mortgage_plus_deposit_less_than_discounted_value?
    return unless mortgage && deposit && value && discount

    discounted_value = value * (100 - discount) / 100
    mortgage + deposit < discounted_value
  end

  def hodate_3_years_or_more_saledate?
    return unless hodate && saledate

    saledate - hodate >= 3.years
  end

  def purchase_price_min_or_max_text
    value < sale_range.soft_min ? "minimum" : "maximum"
  end

  def purchase_price_soft_min_or_soft_max
    value < sale_range.soft_min ? sale_range.soft_min : sale_range.soft_max
  end

  def grant_outside_common_range?
    return unless grant

    !grant.between?(9_000, 16_000)
  end

  def monthly_charges_over_soft_max?
    return unless type && mscharge && proptype

    soft_max = old_persons_shared_ownership? ? 550 : 300
    mscharge > soft_max
  end

private

  def sale_range
    LaSaleRange.find_by(start_year: collection_start_year, la:, bedrooms: beds)
  end
end
