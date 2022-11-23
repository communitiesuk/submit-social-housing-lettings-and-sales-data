module Validations::SetupValidations
  def validate_irproduct_other(record)
    if intermediate_product_rent_type?(record) && record.irproduct_other.blank?
      record.errors.add :irproduct_other, I18n.t("validations.setup.intermediate_rent_product_name.blank")
    end
  end

  def validate_location(record)
    status_during_startdate = record.location&.status_during(record.startdate)
    if status_during_startdate.present? && status_during_startdate[:status] == :deactivated
      record.errors.add :location_id, I18n.t("validations.setup.startdate.during_deactivated_location", postcode: record.location.postcode, date: status_during_startdate[:date].to_formatted_s(:govuk_date))
    end

    if status_during_startdate.present? && status_during_startdate[:status] == :reactivating_soon
      record.errors.add :location_id, I18n.t("validations.setup.startdate.location_reactivating_soon", postcode: record.location.postcode, date: status_during_startdate[:date].to_formatted_s(:govuk_date))
    end
  end

  def validate_scheme(record)
    status_during_startdate = record.location&.status_during(record.startdate)
    if status_during_startdate.present? && status_during_startdate[:status] == :deactivated
      record.errors.add :scheme_id, I18n.t("validations.setup.startdate.during_deactivated_location", postcode: record.location.postcode, date: status_during_startdate[:date].to_formatted_s(:govuk_date))
    end

    if status_during_startdate.present? && status_during_startdate[:status] == :reactivating_soon
      record.errors.add :scheme_id, I18n.t("validations.setup.startdate.location_reactivating_soon", postcode: record.location.postcode, date: status_during_startdate[:date].to_formatted_s(:govuk_date))
    end
  end

private

  def intermediate_product_rent_type?(record)
    record.rent_type == 5
  end
end
