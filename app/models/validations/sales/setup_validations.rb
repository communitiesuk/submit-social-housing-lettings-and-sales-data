module Validations::Sales::SetupValidations
  include Validations::SharedValidations
  include CollectionTimeHelper

  def validate_saledate_collection_year(record)
    return unless record.saledate && date_valid?("saledate", record) && FeatureToggle.saledate_collection_window_validation_enabled?

    first_collection_start_date = if record.saledate_was.present?
                                    editable_collection_start_date
                                  else
                                    active_collection_start_date
                                  end

    unless record.saledate.between?(first_collection_start_date, current_collection_end_date)
      record.errors.add :saledate, saledate_validation_error_message
    end
  end

  def validate_saledate_two_weeks(record)
    return unless record.saledate && date_valid?("saledate", record) && FeatureToggle.saledate_two_week_validation_enabled?

    if record.saledate > Time.zone.today + 14.days
      record.errors.add :saledate, I18n.t("validations.setup.saledate.later_than_14_days_after")
    end
  end

  def validate_merged_organisations_saledate(record)
    return unless record.saledate && date_valid?("saledate", record)

    if merged_owning_organisation_inactive?(record)
      record.errors.add :saledate, I18n.t("validations.setup.saledate.invalid_merged_organisations_saledate",
                                          owning_organisation: record.owning_organisation.name,
                                          owning_organisation_merge_date: record.owning_organisation.merge_date.to_formatted_s(:govuk_date),
                                          owning_absorbing_organisation: record.owning_organisation.absorbing_organisation.name)
    end

    if absorbing_owning_organisation_inactive?(record)
      record.errors.add :saledate, I18n.t("validations.setup.saledate.invalid_absorbing_organisations_saledate",
                                          owning_organisation: record.owning_organisation.name,
                                          owning_organisation_available_from: record.owning_organisation.created_at.to_formatted_s(:govuk_date))
    end
  end

  def validate_organisation(record)
    return unless record.saledate && record.owning_organisation

    if record.owning_organisation.present?
      if record.owning_organisation&.merge_date.present? && record.owning_organisation.merge_date < record.saledate
        record.errors.add :owning_organisation_id, I18n.t("validations.setup.owning_organisation.inactive_merged_organisation",
                                                          owning_organisation: record.owning_organisation.name,
                                                          owning_organisation_merge_date: record.owning_organisation.merge_date.to_formatted_s(:govuk_date),
                                                          owning_absorbing_organisation: record.owning_organisation.absorbing_organisation.name)
      elsif record.owning_organisation&.absorbed_organisations.present? && record.owning_organisation.created_at > record.saledate
        record.errors.add :owning_organisation_id, I18n.t("validations.setup.owning_organisation.inactive_absorbing_organisation",
                                                          owning_organisation: record.owning_organisation.name,
                                                          owning_organisation_available_from: record.owning_organisation.created_at.to_formatted_s(:govuk_date))
      end
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

  def editable_collection_start_date
    if FormHandler.instance.sales_in_edit_crossover_period?
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

  def merged_owning_organisation_inactive?(record)
    record.owning_organisation&.merge_date.present? && record.owning_organisation.merge_date < record.saledate
  end

  def absorbing_owning_organisation_inactive?(record)
    record.owning_organisation&.absorbed_organisations.present? && record.owning_organisation.created_at > record.saledate
  end
end
