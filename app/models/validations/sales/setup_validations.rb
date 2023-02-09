module Validations::Sales::SetupValidations
  include Validations::SharedValidations

  def validate_saledate(record)
    return unless record.saledate && date_valid?("saledate", record)

    unless record.saledate.between?(Time.zone.local(2022, 4, 1), Time.zone.local(2023, 3, 31)) || !FeatureToggle.saledate_collection_window_validation_enabled?
      record.errors.add :saledate, I18n.t("validations.setup.saledate.financial_year")
    end
  end
end
