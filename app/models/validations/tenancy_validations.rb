module Validations::TenancyValidations
  # Validations methods need to be called 'validate_<page_name>' to run on model save
  # or 'validate_' to run on submit as well
  include Validations::SharedValidations

  def validate_fixed_term_tenancy(record)
    is_present = record.tenancylength.present?
    is_in_range = record.tenancylength.to_i.between?(min_tenancy_length(record), 99)
    conditions = [
      {
        condition: !(record.is_secure_tenancy? || record.is_assured_shorthold_tenancy?) && is_present,
        error: I18n.t("validations.tenancy.length.fixed_term_not_required"),
      },
      {
        condition: (record.is_assured_shorthold_tenancy? && !is_in_range) && is_present,
        error: I18n.t(
          "validations.tenancy.length.shorthold",
          min_tenancy_length: min_tenancy_length(record),
        ),
      },
      {
        condition: record.is_secure_tenancy? && (!is_in_range && is_present),
        error: I18n.t(
          "validations.tenancy.length.secure",
          min_tenancy_length: min_tenancy_length(record),
        ),
      },
    ]

    conditions.each do |condition|
      next unless condition[:condition]

      record.errors.add :tenancylength, condition[:error]
      record.errors.add :tenancy, condition[:error]
    end
  end

  def validate_other_tenancy_type(record)
    validate_other_field(record, 3, :tenancy, :tenancyother, "tenancy type", "other tenancy type")
  end

  def validate_joint_tenancy(record)
    return unless record.collection_start_year && record.joint

    if record.hhmemb == 1 && record.joint == 1 && record.collection_start_year >= 2022
      record.errors.add :joint, :not_joint_tenancy, message: I18n.t("validations.tenancy.not_joint")
      record.errors.add :hhmemb, I18n.t("validations.tenancy.joint_more_than_one_member")
    end
  end

  def min_tenancy_length(record)
    record.is_supported_housing? || record.renttype == 3 ? 1 : 2
  end
end
