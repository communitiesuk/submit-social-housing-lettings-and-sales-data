module Validations::Sales::SetupValidations
  include Validations::SharedValidations
  def validate_saledate(record)
    return unless record.saledate && date_valid?("saledate", record)

    unless Time.zone.local(2022, 4, 1) <= record.saledate && record.saledate < Time.zone.local(2023, 4, 1)
      record.errors.add :saledate, I18n.t("validations.setup.saledate.financial_year")
    end
  end
end
