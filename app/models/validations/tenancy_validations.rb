module Validations::TenancyValidations
  # Validations methods need to be called 'validate_<page_name>' to run on model save
  # or 'validate_' to run on submit as well
  def validate_fixed_term_tenancy(record)
    is_present = record.tenancylength.present?
    is_in_range = record.tenancylength.to_i.between?(2, 99)
    is_secure = record.tenancy == "Secure (including flexible)"
    is_ast = record.tenancy == "Assured Shorthold"
    conditions = [
      { condition: !(is_secure || is_ast) && is_present, error: I18n.t("validations.tenancy.length.fixed_term_not_required") },
      { condition: (is_ast && !is_in_range) && is_present, error: I18n.t("validations.tenancy.length.shorthold") },
      { condition: is_secure && (!is_in_range && is_present), error: I18n.t("validations.tenancy.length.secure") },
    ]

    conditions.each do |condition|
      next unless condition[:condition]

      record.errors.add :tenancylength, condition[:error]
      record.errors.add :tenancy, condition[:error]
    end
  end

  def validate_other_tenancy_type(record)
    validate_other_field(record, "tenancy", "tenancyother")
  end
end
