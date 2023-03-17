module Validations::Sales::FinancialValidations
  # Validations methods need to be called 'validate_<page_name>' to run on model save
  # or 'validate_' to run on submit as well

  def validate_income1(record)
    return unless record.income1 && record.la && record.shared_ownership_scheme?

    relevant_fields = %i[income1 ownershipsch la postcode_full]
    if record.london_property? && record.income1 > 90_000
      relevant_fields.each { |field| record.errors.add field, I18n.t("validations.financial.income.over_hard_max_for_london") }
    elsif record.property_not_in_london? && record.income1 > 80_000
      relevant_fields.each { |field| record.errors.add field, I18n.t("validations.financial.income.over_hard_max_for_outside_london") }
    end
  end

  def validate_income2(record)
    return unless record.income2 && record.la && record.shared_ownership_scheme?

    relevant_fields = %i[income2 ownershipsch la postcode_full]
    if record.london_property? && record.income2 > 90_000
      relevant_fields.each { |field| record.errors.add field, I18n.t("validations.financial.income.over_hard_max_for_london") }
    elsif record.property_not_in_london? && record.income2 > 80_000
      relevant_fields.each { |field| record.errors.add field, I18n.t("validations.financial.income.over_hard_max_for_outside_london") }
    end
  end

  def validate_combined_income(record)
    return unless record.income1 && record.income2 && record.la && record.shared_ownership_scheme?

    combined_income = record.income1 + record.income2
    relevant_fields = %i[income1 income2 ownershipsch la postcode_full]
    if record.london_property? && combined_income > 90_000
      relevant_fields.each { |field| record.errors.add field, I18n.t("validations.financial.income.combined_over_hard_max_for_london") }
    elsif record.property_not_in_london? && combined_income > 80_000
      relevant_fields.each { |field| record.errors.add field, I18n.t("validations.financial.income.combined_over_hard_max_for_outside_london") }
    end
  end

  def validate_cash_discount(record)
    return unless record.cashdis

    unless record.cashdis.between?(0, 999_999)
      record.errors.add :cashdis, I18n.t("validations.financial.cash_discount_invalid")
    end
  end

  def validate_percentage_bought_not_greater_than_percentage_owned(record)
    return unless record.stairbought && record.stairowned

    if record.stairbought > record.stairowned
      record.errors.add :stairowned, I18n.t("validations.financial.staircasing.percentage_bought_must_be_greater_than_percentage_owned")
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
      record.errors.add :stairbought, I18n.t("validations.financial.staircasing.percentage_bought_must_be_at_least_threshold", threshold:)
      record.errors.add :type, I18n.t("validations.setup.type.percentage_bought_must_be_at_least_threshold", threshold:)
    end
  end

  def validate_child_income(record)
    return unless record.income2 && record.ecstat2

    if record.income2.positive? && is_economic_status_child?(record.ecstat2)
      record.errors.add :ecstat2, I18n.t("validations.financial.income.child_has_income")
      record.errors.add :income2, I18n.t("validations.financial.income.child_has_income")
    end
  end

  def validate_percentage_owned_not_too_much_if_older_person(record)
    return unless record.old_persons_shared_ownership? && record.stairowned

    if record.stairowned > 75
      record.errors.add :stairowned, I18n.t("validations.financial.staircasing.older_person_percentage_owned_maximum_75")
      record.errors.add :type, I18n.t("validations.financial.staircasing.older_person_percentage_owned_maximum_75")
    end
  end

  def validate_equity_in_range_for_year_and_type(record)
    return unless record.type && record.equity && record.collection_start_year

    ranges = EQUITY_RANGES_BY_YEAR.fetch(record.collection_start_year, DEFAULT_EQUITY_RANGES)

    return unless (range = ranges[record.type])

    if record.equity < range.min
      record.errors.add :type, I18n.t("validations.financial.equity.under_min", min_equity: range.min)
      record.errors.add :equity, I18n.t("validations.financial.equity.under_min", min_equity: range.min)
    elsif record.equity > range.max
      record.errors.add :type, I18n.t("validations.financial.equity.over_max", max_equity: range.max)
      record.errors.add :equity, I18n.t("validations.financial.equity.over_max", max_equity: range.max)
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
    2 => 10..75,
    30 => 25..75,
    18 => 25..75,
    16 => 10..75,
    24 => 25..75,
    31 => 0..75,
    32 => 0..75,
  }.freeze
end
