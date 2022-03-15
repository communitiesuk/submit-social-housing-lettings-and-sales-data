module Validations::SetupValidations
  def validate_intermediate_rent_product_name(record)
    if intermediate_product_rent_type?(record) && record.intermediate_rent_product_name.blank?
      record.errors.add :intermediate_rent_product_name, I18n.t("validations.setup.intermediate_rent_product_name.blank")
    end
  end

private

  def intermediate_product_rent_type?(record)
    record.rent_type == 5
  end
end
