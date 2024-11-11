module Validations::SetupValidations
  include Validations::SharedValidations
  include CollectionTimeHelper

  def validate_startdate_setup(record)
    return unless record.startdate && date_valid?("startdate", record) && !FeatureToggle.allow_future_form_use?

    first_collection_start_date = if record.startdate_was.present?
                                    editable_collection_start_date
                                  else
                                    active_collection_start_date
                                  end

    unless record.startdate.between?(first_collection_start_date, current_collection_end_date)
      record.errors.add :startdate, startdate_validation_error_message
    end

    if record.startdate > Time.zone.today + 14.days
      record.errors.add :startdate, I18n.t("validations.lettings.setup.startdate.not_within.next_two_weeks")
    end
  end

  def validate_organisation(record)
    assigned_to, managing_organisation, owning_organisation = record.values_at("assigned_to", "managing_organisation", "owning_organisation")
    unless [assigned_to, managing_organisation, owning_organisation].any?(&:blank?) || ((assigned_to.organisation.absorbed_organisations + [assigned_to.organisation]) & [managing_organisation, owning_organisation]).present?
      record.errors.add :assigned_to, I18n.t("validations.lettings.setup.assigned_to.invalid")
      record.errors.add :owning_organisation_id, I18n.t("validations.lettings.setup.owning_organisation.invalid")
      record.errors.add :managing_organisation_id, I18n.t("validations.lettings.setup.managing_organisation.invalid")
    end
    return unless record.startdate

    if owning_organisation.present?
      if owning_organisation&.merge_date.present? && owning_organisation.merge_date <= record.startdate
        record.errors.add :owning_organisation_id, I18n.t("validations.lettings.setup.owning_organisation.inactive.merged_organisation",
                                                          owning_organisation: record.owning_organisation.name,
                                                          merge_date: record.owning_organisation.merge_date.to_formatted_s(:govuk_date),
                                                          absorbing_organisation: record.owning_organisation.absorbing_organisation.name)
      elsif owning_organisation&.absorbed_organisations.present? && owning_organisation.available_from.present? && owning_organisation.available_from.to_date > record.startdate.to_date
        record.errors.add :owning_organisation_id, I18n.t("validations.lettings.setup.owning_organisation.inactive.absorbing_organisation",
                                                          owning_organisation: record.owning_organisation.name,
                                                          available_from: record.owning_organisation.available_from.to_formatted_s(:govuk_date))
      end
    end

    if managing_organisation.present?
      if managing_organisation&.merge_date.present? && managing_organisation.merge_date <= record.startdate
        record.errors.add :managing_organisation_id, I18n.t("validations.lettings.setup.managing_organisation.inactive.merged_organisation",
                                                            managing_organisation: record.managing_organisation.name,
                                                            merge_date: record.managing_organisation.merge_date.to_formatted_s(:govuk_date),
                                                            absorbing_organisation: record.managing_organisation.absorbing_organisation.name)
      elsif managing_organisation&.absorbed_organisations.present? && managing_organisation.available_from.present? && managing_organisation.available_from.to_date > record.startdate.to_date
        record.errors.add :managing_organisation_id, I18n.t("validations.lettings.setup.managing_organisation.inactive.absorbing_organisation",
                                                            managing_organisation: record.managing_organisation.name,
                                                            available_from: record.managing_organisation.available_from.to_formatted_s(:govuk_date))
      end
    end
  end

  def validate_merged_organisations_start_date(record)
    return unless record.startdate && date_valid?("startdate", record)

    return add_same_merge_organisation_error(record) if record.owning_organisation == record.managing_organisation
    return add_same_merge_error(record) if organisations_belong_to_same_merge?(record.owning_organisation, record.managing_organisation)

    add_merged_organisations_errors(record)
    add_absorbing_organisations_errors(record)
  end

  def validate_irproduct_other(record)
    if intermediate_product_rent_type?(record) && record.irproduct_other.blank?
      record.errors.add :irproduct_other, I18n.t("validations.lettings.setup.intermediate_rent_product_name.blank")
    end
  end

  def validate_scheme(record)
    return unless record.scheme

    if record.scheme.status == :incomplete
      record.errors.add :scheme_id, :incomplete, message: I18n.t("validations.lettings.setup.scheme.incomplete")
    elsif record.scheme.locations.nil? || (record.scheme.locations.present? && record.scheme.locations.confirmed.none?)
      record.errors.add :scheme_id, :no_completed_locations, message: I18n.t("validations.lettings.setup.scheme.no_completed_locations")
    end

    scheme_during_startdate_validation(record)
    tenancy_startdate_with_scheme_locations(record)
  end

  def validate_location(record)
    location_during_startdate_validation(record)

    if record.location&.status == :incomplete
      record.errors.add :location_id, :incomplete, message: I18n.t("validations.lettings.setup.location.incomplete")
      record.errors.add :scheme_id, :incomplete, message: I18n.t("validations.lettings.setup.location.incomplete")
    end
  end

  def location_during_startdate_validation(record)
    location_inactive_status = inactive_status(record.startdate, record.location)

    if location_inactive_status.present?
      date, scope, deactivation_date = location_inactive_status.values_at(:date, :scope, :deactivation_date)
      record.errors.add :startdate, :not_active, message: I18n.t("validations.lettings.setup.startdate.location.#{scope}.startdate", postcode: record.location.postcode, date:, deactivation_date:)
      record.errors.add :location_id, :not_active, message: I18n.t("validations.lettings.setup.startdate.location.#{scope}.location_id", postcode: record.location.postcode, date:, deactivation_date:)
      record.errors.add :scheme_id, :not_active, message: I18n.t("validations.lettings.setup.startdate.location.#{scope}.location_id", postcode: record.location.postcode, date:, deactivation_date:)
    end
  end

  def scheme_during_startdate_validation(record)
    scheme_inactive_status = inactive_status(record.startdate, record.scheme)

    if scheme_inactive_status.present?
      date, scope, deactivation_date = scheme_inactive_status.values_at(:date, :scope, :deactivation_date)
      record.errors.add :startdate, I18n.t("validations.lettings.setup.startdate.scheme.#{scope}.startdate", name: record.scheme.service_name, date:, deactivation_date:)
      record.errors.add :scheme_id, I18n.t("validations.lettings.setup.startdate.scheme.#{scope}.scheme_id", name: record.scheme.service_name, date:, deactivation_date:)
    end
  end

  def tenancy_startdate_with_scheme_locations(record)
    return if record.scheme.blank? || record.startdate.blank?
    return if record.scheme.has_active_locations_on_date?(record.startdate)

    record.errors.add :startdate, I18n.t("validations.lettings.setup.startdate.scheme.locations_inactive.startdate", name: record.scheme.service_name)
    record.errors.add :scheme_id, I18n.t("validations.lettings.setup.startdate.scheme.locations_inactive.scheme_id", name: record.scheme.service_name)
  end

  def validate_managing_organisation_data_sharing_agremeent_signed(record)
    return if record.skip_dpo_validation

    if record.managing_organisation_id_changed? && record.managing_organisation.present? && !record.managing_organisation.data_protection_confirmed?
      record.errors.add :managing_organisation_id, I18n.t("validations.lettings.setup.managing_organisation.data_sharing_agreement_not_signed")
    end
  end

  def validate_owning_organisation_data_sharing_agremeent_signed(record)
    return if record.skip_dpo_validation

    if record.owning_organisation_id_changed? && record.owning_organisation.present? && !record.owning_organisation.data_protection_confirmed?
      record.errors.add :owning_organisation_id, I18n.t("validations.lettings.setup.owning_organisation.data_sharing_agreement_not_signed")
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

  def editable_collection_start_date
    if FormHandler.instance.lettings_in_edit_crossover_period?
      previous_collection_start_date
    else
      current_collection_start_date
    end
  end

  def startdate_validation_error_message
    current_end_year_long = current_collection_end_date.strftime("#{current_collection_end_date.day.ordinalize} %B %Y")

    if FormHandler.instance.lettings_in_crossover_period?
      I18n.t(
        "validations.lettings.setup.startdate.must_be_within.previous_and_current_collection_year",
        previous_start_year_short: previous_collection_start_date.strftime("%Y"),
        previous_end_year_short: previous_collection_end_date.strftime("%Y"),
        previous_start_year_long: previous_collection_start_date.strftime("#{previous_collection_start_date.day.ordinalize} %B %Y"),
        current_end_year_short: current_collection_end_date.strftime("%Y"),
        current_end_year_long:,
      )
    else
      I18n.t(
        "validations.lettings.setup.startdate.must_be_within.current_collection_year",
        current_start_year_short: current_collection_start_date.strftime("%Y"),
        current_end_year_short: current_collection_end_date.strftime("%Y"),
        current_start_year_long: current_collection_start_date.strftime("#{current_collection_start_date.day.ordinalize} %B %Y"),
        current_end_year_long:,
      )
    end
  end

  def intermediate_product_rent_type?(record)
    record.rent_type == 5
  end

  def add_same_merge_organisation_error(record)
    if merged_owning_organisation_inactive?(record)
      record.errors.add :startdate, I18n.t("validations.lettings.setup.startdate.invalid_merged_organisations_start_date.same_organisation",
                                           owning_organisation: record.owning_organisation.name,
                                           merge_date: record.owning_organisation.merge_date.to_formatted_s(:govuk_date),
                                           absorbing_organisation: record.owning_organisation.absorbing_organisation.name)
    elsif absorbing_owning_organisation_inactive?(record)
      record.errors.add :startdate, I18n.t("validations.lettings.setup.startdate.invalid_absorbing_organisations_start_date.same_organisation",
                                           owning_organisation: record.owning_organisation.name,
                                           available_from: record.owning_organisation.available_from.to_formatted_s(:govuk_date))
    end
  end

  def add_same_merge_error(record)
    if merged_owning_organisation_inactive?(record)
      record.errors.add :startdate, I18n.t("validations.lettings.setup.startdate.invalid_merged_organisations_start_date.same_merge",
                                           owning_organisation: record.owning_organisation.name,
                                           managing_organisation: record.managing_organisation.name,
                                           owning_organisation_merge_date: record.owning_organisation.merge_date.to_formatted_s(:govuk_date),
                                           owning_absorbing_organisation: record.owning_organisation.absorbing_organisation.name)
    end
  end

  def add_merged_organisations_errors(record)
    if merged_owning_organisation_inactive?(record) && merged_managing_organisation_inactive?(record)
      record.errors.add :startdate, I18n.t("validations.lettings.setup.startdate.invalid_merged_organisations_start_date.different_merge",
                                           owning_organisation: record.owning_organisation.name,
                                           owning_organisation_merge_date: record.owning_organisation.merge_date.to_formatted_s(:govuk_date),
                                           owning_absorbing_organisation: record.owning_organisation.absorbing_organisation.name,
                                           managing_organisation: record.managing_organisation.name,
                                           managing_organisation_merge_date: record.managing_organisation.merge_date.to_formatted_s(:govuk_date),
                                           managing_absorbing_organisation: record.managing_organisation.absorbing_organisation.name)
    else
      if merged_owning_organisation_inactive?(record)
        record.errors.add :startdate, I18n.t("validations.lettings.setup.startdate.invalid_merged_organisations_start_date.owning_organisation",
                                             owning_organisation: record.owning_organisation.name,
                                             merge_date: record.owning_organisation.merge_date.to_formatted_s(:govuk_date),
                                             absorbing_organisation: record.owning_organisation.absorbing_organisation.name)
      end

      if merged_managing_organisation_inactive?(record)
        record.errors.add :startdate, I18n.t("validations.lettings.setup.startdate.invalid_merged_organisations_start_date.managing_organisation",
                                             managing_organisation: record.managing_organisation.name,
                                             merge_date: record.managing_organisation.merge_date.to_formatted_s(:govuk_date),
                                             absorbing_organisation: record.managing_organisation.absorbing_organisation.name)
      end
    end
  end

  def add_absorbing_organisations_errors(record)
    if absorbing_owning_organisation_inactive?(record) && absorbing_managing_organisation_inactive?(record)
      record.errors.add :startdate, I18n.t("validations.lettings.setup.startdate.invalid_absorbing_organisations_start_date.different_organisations",
                                           owning_organisation: record.owning_organisation.name,
                                           owning_organisation_active_from: record.owning_organisation.available_from.to_formatted_s(:govuk_date),
                                           managing_organisation: record.managing_organisation.name,
                                           managing_organisation_active_from: record.managing_organisation.available_from.to_formatted_s(:govuk_date))
    else
      if absorbing_owning_organisation_inactive?(record)
        record.errors.add :startdate, I18n.t("validations.lettings.setup.startdate.invalid_absorbing_organisations_start_date.owning_organisation",
                                             owning_organisation: record.owning_organisation.name,
                                             available_from: record.owning_organisation.available_from.to_formatted_s(:govuk_date))
      end

      if absorbing_managing_organisation_inactive?(record)
        record.errors.add :startdate, I18n.t("validations.lettings.setup.startdate.invalid_absorbing_organisations_start_date.managing_organisation",
                                             managing_organisation: record.managing_organisation.name,
                                             available_from: record.managing_organisation.available_from.to_formatted_s(:govuk_date))
      end
    end
  end

  def merged_owning_organisation_inactive?(record)
    record.owning_organisation&.merge_date.present? && record.owning_organisation.merge_date <= record.startdate
  end

  def merged_managing_organisation_inactive?(record)
    record.managing_organisation&.merge_date.present? && record.managing_organisation.merge_date <= record.startdate
  end

  def absorbing_owning_organisation_inactive?(record)
    record.owning_organisation&.absorbed_organisations.present? && record.owning_organisation.available_from.present? && record.owning_organisation.available_from.to_date > record.startdate.to_date
  end

  def absorbing_managing_organisation_inactive?(record)
    record.managing_organisation&.absorbed_organisations.present? && record.managing_organisation.available_from.present? && record.managing_organisation.available_from.to_date > record.startdate.to_date
  end

  def organisations_belong_to_same_merge?(organisation_a, organisation_b)
    organisation_a&.merge_date.present? && organisation_b&.merge_date.present? && organisation_a.merge_date == organisation_b.merge_date && organisation_a.absorbing_organisation == organisation_b.absorbing_organisation
  end
end
