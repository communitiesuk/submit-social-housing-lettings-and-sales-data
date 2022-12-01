module Validations::SetupValidations
  include Validations::SharedValidations

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

private

  def intermediate_product_rent_type?(record)
    record.rent_type == 5
  end
end
