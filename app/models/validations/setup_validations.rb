module Validations::SetupValidations
  include Validations::SharedValidations
  include CollectionTimeHelper

  def validate_startdate(record)
    return unless record.startdate && date_valid?("startdate", record)

    unless record.startdate.between?(active_collection_start_date, current_collection_end_date) || !FeatureToggle.startdate_collection_window_validation_enabled?
      record.errors.add :startdate, validation_error_message
    end

    if FeatureToggle.startdate_two_week_validation_enabled? && record.startdate > Time.zone.today + 14
      record.errors.add :startdate, I18n.t("validations.setup.startdate.later_than_14_days_after")
    end

    if record.scheme_id.present?
      scheme_end_date = record.scheme.end_date
      if scheme_end_date.present? && record.startdate > scheme_end_date
        record.errors.add :startdate, I18n.t("validations.setup.startdate.before_scheme_end_date")
      end
    end

    if record["voiddate"].present? && record.startdate < record["voiddate"]
      record.errors.add :startdate, I18n.t("validations.setup.startdate.after_void_date")
    end

    if record["mrcdate"].present? && record.startdate < record["mrcdate"]
      record.errors.add :startdate, I18n.t("validations.setup.startdate.after_major_repair_date")
    end

    location_during_startdate_validation(record, :startdate)
    scheme_during_startdate_validation(record, :startdate)
  end

  def validate_irproduct_other(record)
    if intermediate_product_rent_type?(record) && record.irproduct_other.blank?
      record.errors.add :irproduct_other, I18n.t("validations.setup.intermediate_rent_product_name.blank")
    end
  end

  def validate_location(record)
    location_during_startdate_validation(record, :location_id)
  end

  def validate_scheme(record)
    location_during_startdate_validation(record, :scheme_id)
    scheme_during_startdate_validation(record, :scheme_id)
  end

  def validate_organisation(record)
    created_by, managing_organisation, owning_organisation = record.values_at("created_by", "managing_organisation", "owning_organisation")
    unless [created_by, managing_organisation, owning_organisation].any?(&:blank?) || created_by.organisation == managing_organisation || created_by.organisation == owning_organisation
      record.errors.add :created_by, I18n.t("validations.setup.created_by.invalid")
      record.errors.add :owning_organisation_id, I18n.t("validations.setup.owning_organisation.invalid")
      record.errors.add :managing_organisation_id, I18n.t("validations.setup.managing_organisation.invalid")
    end
  end

private

  def active_collection_start_date
    if FormHandler.instance.lettings_in_crossover_period?
      previous_collection_start_date
    else
      current_collection_start_date
    end
  end

  def validation_error_message
    current_end_year_long = current_collection_end_date.strftime("#{current_collection_end_date.day.ordinalize} %B %Y")

    if FormHandler.instance.lettings_in_crossover_period?
      I18n.t(
        "validations.setup.startdate.previous_and_current_financial_year",
        previous_start_year_short: previous_collection_start_date.strftime("%y"),
        previous_end_year_short: previous_collection_end_date.strftime("%y"),
        previous_start_year_long: previous_collection_start_date.strftime("#{previous_collection_start_date.day.ordinalize} %B %Y"),
        current_end_year_short: current_collection_end_date.strftime("%y"),
        current_end_year_long:,
      )
    else
      I18n.t(
        "validations.setup.startdate.current_financial_year",
        current_start_year_short: current_collection_start_date.strftime("%y"),
        current_end_year_short: current_collection_end_date.strftime("%y"),
        current_start_year_long: current_collection_start_date.strftime("#{current_collection_start_date.day.ordinalize} %B %Y"),
        current_end_year_long:,
      )
    end
  end

  def intermediate_product_rent_type?(record)
    record.rent_type == 5
  end
end
