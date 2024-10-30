module Validations::Sales::SetupValidations
  include Validations::SharedValidations
  include CollectionTimeHelper

  def validate_saledate_collection_year(record)
    return unless record.saledate && date_valid?("saledate", record) && !FeatureToggle.allow_future_form_use?

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
    return unless record.saledate && date_valid?("saledate", record) && !FeatureToggle.allow_future_form_use?

    if record.saledate > Time.zone.today + 14.days
      record.errors.add :saledate, I18n.t("validations.sales.setup.saledate.not_within.next_two_weeks")
    end
  end

  def validate_merged_organisations_saledate(record)
    return unless record.saledate && date_valid?("saledate", record)

    if merged_owning_organisation_inactive?(record)
      record.errors.add :saledate, I18n.t("validations.sales.setup.saledate.invalid.merged_organisations",
                                          owning_organisation: record.owning_organisation.name,
                                          merge_date: record.owning_organisation.merge_date.to_formatted_s(:govuk_date),
                                          absorbing_organisation: record.owning_organisation.absorbing_organisation.name)
    end

    if absorbing_owning_organisation_inactive?(record)
      record.errors.add :saledate, I18n.t("validations.sales.setup.saledate.invalid.absorbing_organisations",
                                          owning_organisation: record.owning_organisation.name,
                                          available_from: record.owning_organisation.available_from.to_formatted_s(:govuk_date))
    end
  end

  def validate_organisation(record)
    return unless record.saledate && record.owning_organisation

    if record.owning_organisation.present?
      if record.owning_organisation&.merge_date.present? && record.owning_organisation.merge_date <= record.saledate
        record.errors.add :owning_organisation_id, I18n.t("validations.sales.setup.owning_organisation.inactive.merged_organisation",
                                                          owning_organisation: record.owning_organisation.name,
                                                          merge_date: record.owning_organisation.merge_date.to_formatted_s(:govuk_date),
                                                          absorbing_organisation: record.owning_organisation.absorbing_organisation.name)
      elsif record.owning_organisation&.absorbed_organisations.present? && record.owning_organisation.available_from.present? && record.owning_organisation.available_from.to_date > record.saledate.to_date
        record.errors.add :owning_organisation_id, I18n.t("validations.sales.setup.owning_organisation.inactive.absorbing_organisation",
                                                          owning_organisation: record.owning_organisation.name,
                                                          available_from: record.owning_organisation.available_from.to_formatted_s(:govuk_date))
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
    if FormHandler.instance.sales_in_crossover_period?
      I18n.t(
        "validations.sales.setup.saledate.must_be_within.previous_and_current_collection_year",
        previous_start_year_short: previous_collection_start_date.strftime("%Y"),
        previous_end_year_short: previous_collection_end_date.strftime("%Y"),
        previous_start_year_long: previous_collection_start_date.strftime("#{previous_collection_start_date.day.ordinalize} %B %Y"),
        current_end_year_short: current_collection_end_date.strftime("%Y"),
        current_end_year_long: current_collection_end_date.strftime("#{current_collection_end_date.day.ordinalize} %B %Y"),
      )
    else
      I18n.t(
        "validations.sales.setup.saledate.must_be_within.current_collection_year",
        current_start_year_short: current_collection_start_date.strftime("%Y"),
        current_start_year_long: current_collection_start_date.strftime("#{current_collection_start_date.day.ordinalize} %B %Y"),
        current_end_year_short: current_collection_end_date.strftime("%Y"),
        current_end_year_long: current_collection_end_date.strftime("#{current_collection_end_date.day.ordinalize} %B %Y"),
      )
    end
  end

  def merged_owning_organisation_inactive?(record)
    record.owning_organisation&.merge_date.present? && record.owning_organisation.merge_date <= record.saledate
  end

  def absorbing_owning_organisation_inactive?(record)
    record.owning_organisation&.absorbed_organisations.present? && record.owning_organisation.available_from.present? && record.owning_organisation.available_from.to_date > record.saledate.to_date
  end
end
