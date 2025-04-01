module Validations::Sales::FinancialValidations
  # Validations methods need to be called 'validate_<page_name>' to run on model save
  # or 'validate_' to run on submit as well

  def validate_income1(record)
    return unless record.income1 && record.la && record.shared_ownership_scheme?

    relevant_fields = %i[income1 ownershipsch uprn la postcode_full uprn_selection]
    if record.london_property? && !record.income1.between?(0, 90_000)
      relevant_fields.each { |field| record.errors.add field, :outside_london_income_range, message: I18n.t("validations.sales.financial.#{field}.outside_london_income_range") }
    elsif record.property_not_in_london? && !record.income1.between?(0, 80_000)
      relevant_fields.each { |field| record.errors.add field, :outside_non_london_income_range, message: I18n.t("validations.sales.financial.#{field}.outside_non_london_income_range") }
    end
  end

  def validate_income2(record)
    return unless record.income2 && record.la && record.shared_ownership_scheme?

    relevant_fields = %i[income2 ownershipsch uprn la postcode_full uprn_selection]
    if record.london_property? && !record.income2.between?(0, 90_000)
      relevant_fields.each { |field| record.errors.add field, :outside_london_income_range, message: I18n.t("validations.sales.financial.#{field}.outside_london_income_range") }
    elsif record.property_not_in_london? && !record.income2.between?(0, 80_000)
      relevant_fields.each { |field| record.errors.add field, :outside_non_london_income_range, message: I18n.t("validations.sales.financial.#{field}.outside_non_london_income_range") }
    end
  end

  def validate_combined_income(record)
    return unless record.income1 && record.income2 && record.la && record.shared_ownership_scheme?

    combined_income = record.income1 + record.income2
    relevant_fields = %i[income1 income2 ownershipsch uprn la postcode_full]
    if record.london_property? && combined_income > 90_000
      relevant_fields.each { |field| record.errors.add field, :over_combined_hard_max_for_london, message: I18n.t("validations.sales.financial.#{field}.combined_over_hard_max_for_london") }
    elsif record.property_not_in_london? && combined_income > 80_000
      relevant_fields.each { |field| record.errors.add field, :over_combined_hard_max_for_outside_london, message: I18n.t("validations.sales.financial.#{field}.combined_over_hard_max_for_outside_london") }
    end
  end

  def validate_mortgage(record)
    record.errors.add :mortgage, :cannot_be_0, message: I18n.t("validations.sales.financial.mortgage.mortgage_zero") if record.mortgage_used? && record.mortgage&.zero?
  end

  def validate_monthly_leasehold_charges(record)
    record.errors.add :mscharge, I18n.t("validations.sales.financial.mscharge.monthly_leasehold_charges.not_zero") if record.mscharge&.zero?
  end

  def validate_percentage_bought_not_greater_than_percentage_owned(record)
    return unless record.stairbought && record.stairowned

    if record.stairbought > record.stairowned
      joint_purchase_id = record.joint_purchase? ? "joint_purchase" : "not_joint_purchase"
      record.errors.add :stairowned, I18n.t("validations.sales.financial.stairowned.percentage_bought_must_be_greater_than_percentage_owned.#{joint_purchase_id}")
    end
  end

  def validate_percentage_bought_not_equal_percentage_owned(record)
    return unless record.stairbought && record.stairowned
    return unless record.saledate && record.form.start_year_2024_or_later?

    if record.stairbought == record.stairowned
      record.errors.add :stairbought, I18n.t("validations.sales.financial.stairbought.percentage_bought_equal_percentage_owned", stairbought: sprintf("%g", record.stairbought), stairowned: sprintf("%g", record.stairowned))
      record.errors.add :stairowned, I18n.t("validations.sales.financial.stairowned.percentage_bought_equal_percentage_owned", stairbought: sprintf("%g", record.stairbought), stairowned: sprintf("%g", record.stairowned))
    end
  end

  def validate_percentage_bought_at_least_threshold(record)
    return unless record.stairbought && record.type

    threshold = if [2, 16, 18, 24].include? record.type
                  10
                else
                  1
                end

    if threshold && record.stairbought < threshold
      shared_ownership_type = record.form.get_question("type", record).label_from_value(record.type).downcase
      record.errors.add :stairbought, I18n.t("validations.sales.financial.stairbought.percentage_bought_must_be_at_least_threshold", threshold:, shared_ownership_type:)
      record.errors.add :type, :skip_bu_error, message: I18n.t("validations.sales.financial.type.percentage_bought_must_be_at_least_threshold", threshold:, shared_ownership_type:)
    end
  end

  def validate_child_income(record)
    return unless record.income2 && record.ecstat2

    if record.income2.positive? && is_economic_status_child?(record.ecstat2)
      record.errors.add :ecstat2, I18n.t("validations.sales.financial.ecstat2.child_has_income")
      record.errors.add :income2, I18n.t("validations.sales.financial.income2.child_has_income")
    end
  end

  def validate_equity_in_range_for_year_and_type(record)
    return unless record.type && record.equity && record.collection_start_year

    ranges = EQUITY_RANGES_BY_YEAR.fetch(record.collection_start_year, DEFAULT_EQUITY_RANGES)

    return unless (range = ranges[record.type])

    if record.equity < range.min
      record.errors.add :type, :skip_bu_error, message: I18n.t("validations.sales.financial.type.equity_under_min", min_equity: range.min)
      record.errors.add :equity, :under_min, message: I18n.t("validations.sales.financial.equity.equity_under_min", min_equity: range.min)
    elsif !record.is_resale? && record.equity > range.max
      record.errors.add :type, :skip_bu_error, message: I18n.t("validations.sales.financial.type.equity_over_max", max_equity: range.max)
      record.errors.add :equity, :over_max, message: I18n.t("validations.sales.financial.equity.equity_over_max", max_equity: range.max)
      record.errors.add :resale, I18n.t("validations.sales.financial.resale.equity_over_max", max_equity: range.max)
    end
  end

  def validate_staircase_difference(record)
    return unless record.equity && record.stairbought && record.stairowned
    return unless record.saledate && record.form.start_year_2024_or_later?

    percentage_left = record.stairowned - record.stairbought - record.equity

    if percentage_left.negative?
      formatted_equity = sprintf("%g", record.equity)
      joint_purchase_id = record.joint_purchase? ? "joint_purchase" : "not_joint_purchase"

      record.errors.add :equity, I18n.t("validations.sales.financial.equity.equity_over_stairowned_minus_stairbought.#{joint_purchase_id}", equity: formatted_equity, staircase_difference: record.stairowned - record.stairbought)
      record.errors.add :stairowned, I18n.t("validations.sales.financial.stairowned.equity_over_stairowned_minus_stairbought.#{joint_purchase_id}", equity: formatted_equity, staircase_difference: record.stairowned - record.stairbought)
      record.errors.add :stairbought, I18n.t("validations.sales.financial.stairbought.equity_over_stairowned_minus_stairbought.#{joint_purchase_id}", equity: formatted_equity, staircase_difference: record.stairowned - record.stairbought)

    elsif record.numstair
      # We must use the lowest possible percentage for a staircasing transaction of any saletype, any year since 1980
      minimum_percentage_per_staircasing_transaction = 1
      previous_staircasing_transactions = record.numstair - 1

      if percentage_left < previous_staircasing_transactions * minimum_percentage_per_staircasing_transaction
        equity_sum = sprintf("%g", record.stairowned - percentage_left + previous_staircasing_transactions * minimum_percentage_per_staircasing_transaction)
        formatted_equity = sprintf("%g", record.equity)
        formatted_stairbought = sprintf("%g", record.stairbought)
        formatted_stairowned = sprintf("%g", record.stairowned)

        record.errors.add :equity, I18n.t("validations.sales.financial.equity.more_than_stairowned_minus_stairbought_minus_prev_staircasing", equity: formatted_equity, bought: formatted_stairbought, numprevstair: previous_staircasing_transactions, equity_sum:, stair_total: formatted_stairowned)
        record.errors.add :stairowned, I18n.t("validations.sales.financial.stairowned.less_than_stairbought_plus_equity_plus_prev_staircasing", equity: formatted_equity, bought: formatted_stairbought, numprevstair: previous_staircasing_transactions, equity_sum:, stair_total: formatted_stairowned)
        record.errors.add :stairbought, I18n.t("validations.sales.financial.stairbought.more_than_stairowned_minus_equity_minus_prev_staircasing", equity: formatted_equity, bought: formatted_stairbought, numprevstair: previous_staircasing_transactions, equity_sum:, stair_total: formatted_stairowned)
        record.errors.add :numstair, I18n.t("validations.sales.financial.numstair.too_high_for_stairowned_minus_stairbought_minus_equity", equity: formatted_equity, bought: formatted_stairbought, numprevstair: previous_staircasing_transactions, equity_sum:, stair_total: formatted_stairowned)
        record.errors.add :firststair, I18n.t("validations.sales.financial.firststair.invalid_for_stairowned_minus_stairbought_minus_equity", equity: formatted_equity, bought: formatted_stairbought, numprevstair: previous_staircasing_transactions, equity_sum:, stair_total: formatted_stairowned)
      end
    end
  end

private

  def is_relationship_child?(relationship)
    relationship == "C"
  end

  def is_economic_status_child?(economic_status)
    economic_status == 9
  end

  EQUITY_RANGES_BY_YEAR = {
    2022 => {
      2 => 25..75,
      30 => 10..75,
      18 => 25..75,
      16 => 10..75,
      24 => 25..75,
      31 => 0..75,
    },
  }.freeze

  DEFAULT_EQUITY_RANGES = {
    2 => 25..75,
    30 => 10..75,
    18 => 25..75,
    16 => 10..75,
    24 => 25..75,
    31 => 0..75,
    32 => 0..75,
  }.freeze
end
