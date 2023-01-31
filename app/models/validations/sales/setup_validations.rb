module Validations::Sales::SetupValidations
  def validate_saledate(record)
    return unless record.saledate

    unless Time.zone.local(2022, 4, 1) <= record.saledate && record.saledate < Time.zone.local(2023, 4, 1)
      record.errors.add :saledate, I18n.t("validations.setup.saledate.financial_year")
    end
  end
end
