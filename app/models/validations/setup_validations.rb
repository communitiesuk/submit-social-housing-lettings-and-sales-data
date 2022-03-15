module Validations::SetupValidations
  def validate_intermediate_rent_product_name(record)
    if record.rent_type == 5 && record.intermediate_rent_product_name.blank?
      record.errors.add :intermediate_rent_product_name, I18n.t("validations.setup.intermediate_rent_product_name.blank")
    end
  end
end
