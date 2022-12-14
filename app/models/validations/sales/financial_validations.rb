module Validations::Sales::FinancialValidations
  # Validations methods need to be called 'validate_<page_name>' to run on model save
  # or 'validate_' to run on submit as well

  def validate_income1(record)
    if record.ecstat1 && record.income1 && record.la && record.ownershipsch == 1
      if record.london_property?
        record.errors.add :income1, I18n.t("validations.financial.income1.over_hard_max", hard_max: 90_000) if record.income1 > 90_000
        record.errors.add :ecstat1, I18n.t("validations.financial.income1.over_hard_max", hard_max: 90_000) if record.income1 > 90_000
        record.errors.add :ownershipsch, I18n.t("validations.financial.income1.over_hard_max", hard_max: 90_000) if record.income1 > 90_000
        record.errors.add :la, I18n.t("validations.financial.income1.over_hard_max", hard_max: 90_000) if record.income1 > 90_000
        record.errors.add :postcode_full, I18n.t("validations.financial.income1.over_hard_max", hard_max: 90_000) if record.income1 > 90_000
      elsif record.income1 > 80_000
        record.errors.add :income1, I18n.t("validations.financial.income1.over_hard_max", hard_max: 80_000)
        record.errors.add :ecstat1, I18n.t("validations.financial.income1.over_hard_max", hard_max: 80_000)
        record.errors.add :ownershipsch, I18n.t("validations.financial.income1.over_hard_max", hard_max: 80_000)
        record.errors.add :la, I18n.t("validations.financial.income1.over_hard_max", hard_max: 80_000) if record.income1 > 80_000
        record.errors.add :postcode_full, I18n.t("validations.financial.income1.over_hard_max", hard_max: 80_000) if record.income1 > 80_000
      end
    end

    if record.income1 && record.income2
      if record.london_property?
        record.errors.add :income1, I18n.t("validations.financial.income.combined_over_hard_max", hard_max: 90_000) if record.income1 + record.income2 > 90_000
      elsif record.income1 + record.income2 > 80_000
        record.errors.add :income1, I18n.t("validations.financial.income.combined_over_hard_max", hard_max: 80_000)
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

  def validate_percentage_owned_not_too_much_if_older_person(record)
    return unless record.old_persons_shared_ownership? && record.stairowned

    if record.stairowned > 75
      record.errors.add :stairowned, I18n.t("validations.financial.staircasing.older_person_percentage_owned_maximum_75")
      record.errors.add :type, I18n.t("validations.financial.staircasing.older_person_percentage_owned_maximum_75")
    end
  def validate_income2(record)
    if record.ecstat2 && record.income2 && record.ownershipsch == 1
      if record.london_property?
        record.errors.add :income2, I18n.t("validations.financial.income.over_hard_max", hard_max: 90_000) if record.income2 > 90_000
      elsif record.income2 > 80_000
        record.errors.add :income2, I18n.t("validations.financial.income.over_hard_max", hard_max: 80_000)
      end
    end

    if record.income1 && record.income2
      if record.london_property?
        record.errors.add :income2, I18n.t("validations.financial.income.combined_over_hard_max", hard_max: 90_000) if record.income1 + record.income2 > 90_000
      elsif record.income1 + record.income2 > 80_000
        record.errors.add :income2, I18n.t("validations.financial.income.combined_over_hard_max", hard_max: 80_000)
      end
    end

    child_income_validation(record, :income2)
  end
end
