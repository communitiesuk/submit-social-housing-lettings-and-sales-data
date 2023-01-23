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

  def mortgage_over_soft_max?
    return false unless mortgage && inc1mort && inc2mort
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

  def hodate_3_years_or_more_saledate?
    return unless hodate && saledate

    ((saledate.to_date - hodate.to_date).to_i / 365) >= 3
  end

  def grant_outside_common_range?
    return unless grant

    !(9_000..16_000).cover? grant
  end
end
