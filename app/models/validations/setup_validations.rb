module Validations::SetupValidations
  include Validations::SharedValidations

  def validate_startdate_setup(record)
    return unless record.startdate && date_valid?("startdate", record)

    created_at = record.created_at || Time.zone.now

    if created_at >= previous_collection_end_date && !record.startdate.between?(current_collection_start_date, next_collection_start_date)
      record.errors.add :startdate, validation_error_message
    end

    if created_at < previous_collection_end_date && !record.startdate.between?(previous_collection_start_date, next_collection_start_date)
      record.errors.add :startdate, validation_error_message
    end
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

  def previous_collection_start_date
    FormHandler.instance.lettings_forms["previous_lettings"].start_date
  end

  def previous_collection_end_date
    FormHandler.instance.lettings_forms["previous_lettings"].end_date
  end

  def current_collection_start_date
    FormHandler.instance.lettings_forms["current_lettings"].start_date
  end

  def current_collection_end_date
    FormHandler.instance.lettings_forms["current_lettings"].end_date
  end

  def next_collection_start_date
    FormHandler.instance.lettings_forms["next_lettings"].start_date
  end

  def intermediate_product_rent_type?(record)
    record.rent_type == 5
  end
end
