module Validations::Sales::SetupValidations
  def validate_saledate(record)
    return unless record.saledate

    if record.saledate < Time.zone.local(2022, 4, 1)
      record.errors.add :saledate, I18n.t("validations.setup.saledate.financial_year")
    end
  end
end
