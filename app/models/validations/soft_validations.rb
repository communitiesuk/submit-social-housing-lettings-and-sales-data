module Validations::SoftValidations
  ALLOWED_INCOME_RANGES = {
    1 => OpenStruct.new(soft_min: 143, soft_max: 730, hard_min: 90, hard_max: 1230),
    0 => OpenStruct.new(soft_min: 67, soft_max: 620, hard_min: 50, hard_max: 950),
    2 => OpenStruct.new(soft_min: 80, soft_max: 480, hard_min: 40, hard_max: 990),
    3 => OpenStruct.new(soft_min: 50, soft_max: 370, hard_min: 10, hard_max: 450),
    4 => OpenStruct.new(soft_min: 50, soft_max: 380, hard_min: 10, hard_max: 690),
    5 => OpenStruct.new(soft_min: 53, soft_max: 540, hard_min: 10, hard_max: 890),
    6 => OpenStruct.new(soft_min: 47, soft_max: 460, hard_min: 10, hard_max: 1300),
    7 => OpenStruct.new(soft_min: 54, soft_max: 460, hard_min: 10, hard_max: 820),
    8 => OpenStruct.new(soft_min: 50, soft_max: 450, hard_min: 10, hard_max: 750),
    9 => OpenStruct.new(soft_min: 50, soft_max: 580, hard_min: 10, hard_max: 1040),
    10 => OpenStruct.new(soft_min: 47, soft_max: 730, hard_min: 10, hard_max: 1300),
  }.freeze

  def has_no_unresolved_soft_errors?
    soft_errors.empty? || soft_errors_overridden?
  end

  def soft_errors
    {}.merge(net_income_validations)
  end

  def soft_errors_overridden?
    public_send(soft_errors.keys.first) == 1 if soft_errors.present?
  end

  def net_income_in_soft_max_range?
    return unless weekly_net_income && ecstat1

    weekly_net_income.between?(applicable_income_range.soft_max, applicable_income_range.hard_max)
  end

  def net_income_in_soft_min_range?
    return unless weekly_net_income && ecstat1

    weekly_net_income.between?(applicable_income_range.hard_min, applicable_income_range.soft_min)
  end

private

  def net_income_validations
    net_income_errors = {}
    if net_income_in_soft_min_range?
      net_income_errors["net_income_value_check"] = OpenStruct.new(
        message: I18n.t("soft_validations.net_income.in_soft_min_range.message"),
        hint_text: I18n.t("soft_validations.net_income.hint_text", ecstat1:),
      )
    elsif net_income_in_soft_max_range?
      net_income_errors["net_income_value_check"] = OpenStruct.new(
        message: I18n.t("soft_validations.net_income.in_soft_max_range.message"),
        hint_text: I18n.t("soft_validations.net_income.hint_text", ecstat1:),
      )
    else
      update_column(:net_income_value_check, nil)
    end
    net_income_errors
  end
end
