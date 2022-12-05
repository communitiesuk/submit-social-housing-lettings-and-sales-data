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

  def validate_organisation(record)
    created_by, managing_organisation, owning_organisation = record.values_at("created_by", "managing_organisation", "owning_organisation")
    unless [created_by, managing_organisation, owning_organisation].any?(&:blank?) || created_by.organisation == managing_organisation || created_by.organisation == owning_organisation
      record.errors.add :created_by, I18n.t("validations.setup.created_by.invalid")
      record.errors.add :owning_organisation_id, I18n.t("validations.setup.owning_organisation.invalid")
      record.errors.add :managing_organisation_id, I18n.t("validations.setup.managing_organisation.invalid")
    end
  end

private

  def intermediate_product_rent_type?(record)
    record.rent_type == 5
  end
end
