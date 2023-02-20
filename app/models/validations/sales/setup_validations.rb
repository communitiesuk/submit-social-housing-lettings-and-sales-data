module Validations::Sales::SetupValidations
  include Validations::SharedValidations
  include CollectionTimeHelper

  def validate_saledate(record)
    return unless record.saledate && date_valid?("saledate", record)

    unless record.saledate.between?(current_collection_start_date, active_collection_end_date)
      record.errors.add :saledate, validation_error_message
    end
  end

private

  def active_collection_end_date
    if FeatureToggle.saledate_next_collection_year_validation_enabled?
      next_collection_end_date
    else
      current_collection_end_date
    end
  end

  def validation_error_message
    start_date = current_collection_start_date
    if FeatureToggle.saledate_next_collection_year_validation_enabled?
      I18n.t(
        "validations.setup.saledate.current_and_next_financial_year",
        current_start_year_short: start_date.strftime("%y"),
        current_end_year_short: current_collection_end_date.strftime("%y"),
        current_start_year_long: start_date.strftime("%Y"),
        next_end_year_short: next_collection_end_date.strftime("%y"),
        next_end_year_long: next_collection_end_date.strftime("%Y"),
      )
    else
      I18n.t(
        "validations.setup.saledate.current_financial_year",
        current_start_year_short: start_date.strftime("%y"),
        current_end_year_short: current_collection_end_date.strftime("%y"),
        current_start_year_long: start_date.strftime("%Y"),
        current_end_year_long: current_collection_end_date.strftime("%Y"),
      )
    end
  end
end
