module Validations::SetupValidations
  def validate_irproduct_other(record)
    if intermediate_product_rent_type?(record) && record.irproduct_other.blank?
      record.errors.add :irproduct_other, I18n.t("validations.setup.intermediate_rent_product_name.blank")
    end
  end

  def validate_location(record)
    if record.location&.status_during(record.startdate) == :deactivated
      record.errors.add :location_id, I18n.t("validations.setup.startdate.during_deactivated_location")
    end

    if record.location&.status_during(record.startdate) == :reactivating_soon
      record.errors.add :location_id, I18n.t("validations.setup.startdate.location_reactivating_soon")
    end
  end
  
private

  def intermediate_product_rent_type?(record)
    record.rent_type == 5
  end
end
