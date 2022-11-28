module Validations::DateValidations
  def validate_property_major_repairs(record)
    date_valid?("mrcdate", record)
    if record["startdate"].present? && record["mrcdate"].present? && record["startdate"] < record["mrcdate"]
      record.errors.add :mrcdate, I18n.t("validations.property.mrcdate.before_tenancy_start")
    end

    if is_rsnvac_first_let?(record) && record["mrcdate"].present?
      record.errors.add :mrcdate, I18n.t("validations.property.mrcdate.not_first_let")
    end

    if record["mrcdate"].present? && record["startdate"].present? && record["startdate"].to_date - record["mrcdate"].to_date > 3650
      record.errors.add :mrcdate, I18n.t("validations.property.mrcdate.ten_years_before_tenancy_start")
    end
  end

  def validate_property_void_date(record)
    if record["voiddate"].present? && record["startdate"].present? && record["startdate"].to_date - record["voiddate"].to_date > 3650
      record.errors.add :voiddate, I18n.t("validations.property.void_date.ten_years_before_tenancy_start")
    end

    if record["voiddate"].present? && record["startdate"].present? && record["startdate"].to_date < record["voiddate"].to_date
      record.errors.add :voiddate, I18n.t("validations.property.void_date.before_tenancy_start")
    end

    if record["voiddate"].present? && record["mrcdate"].present? && record["mrcdate"].to_date < record["voiddate"].to_date
      record.errors.add :voiddate, I18n.t("validations.property.void_date.after_mrcdate")
    end
  end

  def validate_startdate(record)
    return unless record.startdate && date_valid?("startdate", record)

    created_at = record.created_at || Time.zone.now

    if created_at > first_collection_end_date && record.startdate < second_collection_start_date
      record.errors.add :startdate, I18n.t("validations.date.outside_collection_window")
    end

    if record.startdate < first_collection_start_date || record.startdate > second_collection_end_date
      record.errors.add :startdate, I18n.t("validations.date.outside_collection_window")
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

    location_inactive_status = inactive_status(record.startdate, record.location&.location_deactivation_periods, record.location&.available_from)
    if location_inactive_status.present?
      record.errors.add :startdate, I18n.t("validations.setup.startdate.location_#{location_inactive_status[:status]}", postcode: record.location.postcode, date: location_inactive_status[:date].to_formatted_s(:govuk_date), deactivation_date: location_inactive_status[:deactivation_date]&.to_formatted_s(:govuk_date))
    end

    scheme_inactive_status = inactive_status(record.startdate, record.scheme&.scheme_deactivation_periods, record.scheme&.available_from)
    if scheme_inactive_status.present?
      record.errors.add :startdate, I18n.t("validations.setup.startdate.scheme_#{scheme_inactive_status[:status]}", name: record.scheme.service_name, date: scheme_inactive_status[:date].to_formatted_s(:govuk_date), deactivation_date: scheme_inactive_status[:deactivation_date]&.to_formatted_s(:govuk_date))
    end
  end

private

  def first_collection_start_date
    @first_collection_start_date ||= FormHandler.instance.forms.map { |_name, form| form.start_date }.compact.min
  end

  def first_collection_end_date
    @first_collection_end_date ||= FormHandler.instance.forms.map { |_name, form| form.end_date }.compact.min
  end

  def second_collection_start_date
    @second_collection_start_date ||= FormHandler.instance.forms.map { |_name, form| form.start_date }.compact.max
  end

  def second_collection_end_date
    @second_collection_end_date ||= FormHandler.instance.forms.map { |_name, form| form.end_date }.compact.max
  end

  def date_valid?(question, record)
    if record[question].is_a?(ActiveSupport::TimeWithZone) && record[question].year.zero?
      record.errors.add question, I18n.t("validations.date.invalid_date")
      false
    else
      true
    end
  end

  def is_rsnvac_first_let?(record)
    [15, 16, 17].include?(record["rsnvac"])
  end

  def inactive_status(date, deactivation_periods, available_from)
    return if date.blank?

    closest_reactivation = deactivation_periods.order(created_at: :desc).find { |period| period.reactivation_date.present? && date.between?(period.deactivation_date, period.reactivation_date - 1.day) } if deactivation_periods.present?
    return { status: "reactivating_soon", date: closest_reactivation.reactivation_date, deactivation_date: closest_reactivation.deactivation_date } if closest_reactivation.present?
    return { status: "activating_soon", date: available_from } if available_from.present? && available_from > date

    open_deactivation = deactivation_periods.deactivations_without_reactivation.first if deactivation_periods.present?
    return { status: "deactivated", date: open_deactivation.deactivation_date } if open_deactivation.present? && open_deactivation.deactivation_date <= date
  end
end
