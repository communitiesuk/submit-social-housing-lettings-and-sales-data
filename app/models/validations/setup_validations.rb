module Validations::SetupValidations
  def validate_irproduct_other(record)
    if intermediate_product_rent_type?(record) && record.irproduct_other.blank?
      record.errors.add :irproduct_other, I18n.t("validations.setup.intermediate_rent_product_name.blank")
    end
  end

  def validate_location(record)
    validate_location_during_startdate(record, :location_id)
  end

  def validate_scheme(record)
    validate_location_during_startdate(record, :scheme_id)

    scheme_inactive_status = inactive_status(record.startdate, record.scheme&.scheme_deactivation_periods, record.scheme&.available_from)
    if scheme_inactive_status.present?
      record.errors.add :scheme_id, I18n.t("validations.setup.startdate.scheme_#{scheme_inactive_status[:status]}", name: record.scheme.service_name, date: scheme_inactive_status[:date].to_formatted_s(:govuk_date), deactivation_date: scheme_inactive_status[:deactivation_date]&.to_formatted_s(:govuk_date))
    end
  end

private

  def intermediate_product_rent_type?(record)
    record.rent_type == 5
  end

  def inactive_status(date, deactivation_periods, available_from)
    return if date.blank?

    closest_reactivation = deactivation_periods.reverse.find { |period| period.reactivation_date.present? && date.between?(period.deactivation_date, period.reactivation_date - 1.day) } if deactivation_periods.present?
    return { status: "reactivating_soon", date: closest_reactivation.reactivation_date, deactivation_date: closest_reactivation.deactivation_date } if closest_reactivation.present?
    return { status: "activating_soon", date: available_from } if available_from.present? && available_from > date

    open_deactivation = deactivation_periods.deactivations_without_reactivation.first if deactivation_periods.present?
    return { status: "deactivated", date: open_deactivation.deactivation_date } if open_deactivation.present? && open_deactivation.deactivation_date <= date
  end

  def validate_location_during_startdate(record, field)
    location_inactive_status = inactive_status(record.startdate, record.location&.location_deactivation_periods, record.location&.available_from)
    if location_inactive_status.present?
      record.errors.add field, I18n.t("validations.setup.startdate.location_#{location_inactive_status[:status]}", postcode: record.location.postcode, date: location_inactive_status[:date].to_formatted_s(:govuk_date), deactivation_date: location_inactive_status[:deactivation_date]&.to_formatted_s(:govuk_date))
    end
  end
end
