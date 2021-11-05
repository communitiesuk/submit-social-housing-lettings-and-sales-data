module SoftValidations
  def has_no_unresolved_soft_errors?
    soft_errors.empty? || soft_errors_overridden?
  end

  def soft_errors
    {}.merge(net_income_validations)
  end

  def soft_errors_overridden?
    public_send(soft_errors.keys.first) if soft_errors.present?
  end

private

  def net_income_validations
    net_income_errors = {}
    if net_income_in_soft_min_range?
      net_income_errors["override_net_income_validation"] = OpenStruct.new(
        message: "Net income is lower than expected based on the main tenant's working situation. Are you sure this is correct?",
        hint_text: "This is based on the tenant's work situation: #{ecstat1}",
      )
    elsif net_income_in_soft_max_range?
      net_income_errors["override_net_income_validation"] = OpenStruct.new(
        message: "Net income is higher than expected based on the main tenant's working situation. Are you sure this is correct?",
        hint_text: "This is based on the tenant's work situation: #{ecstat1}",
      )
    else
      update_column(:override_net_income_validation, nil)
    end
    net_income_errors
  end

  def net_income_in_soft_max_range?
    return unless weekly_net_income && ecstat1

    weekly_net_income.between?(applicable_income_range.soft_max, applicable_income_range.hard_max)
  end

  def net_income_in_soft_min_range?
    return unless weekly_net_income && ecstat1

    weekly_net_income.between?(applicable_income_range.soft_min, applicable_income_range.hard_min)
  end
end
