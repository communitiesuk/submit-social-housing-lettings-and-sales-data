module Validations::Sales::SetupValidations
  include Validations::SharedValidations
  include CollectionTimeHelper

  def validate_saledate_collection_year(record)
    return unless record.saledate && date_valid?("saledate", record) && FeatureToggle.saledate_collection_window_validation_enabled?

    unless record.saledate.between?(active_collection_start_date, current_collection_end_date)
      record.errors.add :saledate, saledate_validation_error_message
    end
  end

  def validate_saledate_two_weeks(record)
    if FeatureToggle.saledate_two_week_validation_enabled? && record.saledate > Time.zone.today + 14
      record.errors.add :saledate, I18n.t("validations.setup.saledate.later_than_14_days_after")
    end
  end

private

  def active_collection_start_date
    if FormHandler.instance.sales_in_crossover_period?
      previous_collection_start_date
    else
      current_collection_start_date
    end
  end

  def saledate_validation_error_message
    current_end_year_long = current_collection_end_date.strftime("#{current_collection_end_date.day.ordinalize} %B %Y")

    if FormHandler.instance.sales_in_crossover_period?
      I18n.t(
        "validations.setup.saledate.previous_and_current_collection_year",
        previous_start_year_short: previous_collection_start_date.strftime("%y"),
        previous_end_year_short: previous_collection_end_date.strftime("%y"),
        previous_start_year_long: previous_collection_start_date.strftime("#{previous_collection_start_date.day.ordinalize} %B %Y"),
        current_end_year_short: current_collection_end_date.strftime("%y"),
        current_end_year_long:,
      )
    else
      I18n.t(
        "validations.setup.saledate.current_collection_year",
        current_start_year_short: current_collection_start_date.strftime("%y"),
        current_end_year_short: current_collection_end_date.strftime("%y"),
        current_start_year_long: current_collection_start_date.strftime("#{current_collection_start_date.day.ordinalize} %B %Y"),
        current_end_year_long:,
      )
    end
  end
end
