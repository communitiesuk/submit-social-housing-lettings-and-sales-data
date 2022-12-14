module Validations::Sales::SharedValidations
  def child_income_validation(record, field)
    if record.relat2 && record.income2
      if record.relat2 == "C" && record.income2 > 0
        record.errors.add field, I18n.t("validations.financial.income.child_has_income")
      end
    end
  end
end
