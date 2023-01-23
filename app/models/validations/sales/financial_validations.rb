module Validations::Sales::FinancialValidations
  # Validations methods need to be called 'validate_<page_name>' to run on model save
  # or 'validate_' to run on submit as well

  def validate_income1(record)
    if record.ecstat1 && record.income1 && record.ownershipsch == 1
      if record.london_property?
        record.errors.add :income1, I18n.t("validations.financial.income1.over_hard_max", hard_max: 90_000) if record.income1 > 90_000
        record.errors.add :ecstat1, I18n.t("validations.financial.income1.over_hard_max", hard_max: 90_000) if record.income1 > 90_000
        record.errors.add :ownershipsch, I18n.t("validations.financial.income1.over_hard_max", hard_max: 90_000) if record.income1 > 90_000
      elsif record.income1 > 80_000
        record.errors.add :income1, I18n.t("validations.financial.income1.over_hard_max", hard_max: 80_000)
        record.errors.add :ecstat1, I18n.t("validations.financial.income1.over_hard_max", hard_max: 80_000)
        record.errors.add :ownershipsch, I18n.t("validations.financial.income1.over_hard_max", hard_max: 80_000)
      end
    end
  end

  def validate_cash_discount(record)
    return unless record.cashdis

    unless record.cashdis.between?(0, 999_999)
      record.errors.add :cashdis, I18n.t("validations.financial.cash_discount_invalid")
    end
  end
end
