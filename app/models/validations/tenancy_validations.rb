module Validations::TenancyValidations
  # Validations methods need to be called 'validate_<page_name>' to run on model save
  # or 'validate_' to run on submit as well
  include Validations::SharedValidations

  def validate_supported_housing_fixed_tenancy_length(record)
    return unless record.tenancy_type_fixed_term? && record.is_supported_housing?
    return if record.tenancylength.blank?

    min_tenancy_length = 1
    return if record.tenancylength.to_i.between?(min_tenancy_length, 99)

    record.errors.add :needstype, I18n.t("validations.lettings.tenancy.needstype.invalid_fixed_tenancylength", min_tenancy_length:)
    record.errors.add :tenancylength, :tenancylength_invalid, message: I18n.t("validations.lettings.tenancy.tenancylength.invalid_fixed_tenancylength", min_tenancy_length:)
    record.errors.add :tenancy, I18n.t("validations.lettings.tenancy.tenancy.invalid_fixed_tenancylength", min_tenancy_length:)
  end

  def validate_general_needs_fixed_tenancy_length_affordable_social_rent(record)
    return unless record.tenancy_type_fixed_term? && record.affordable_or_social_rent? && record.is_general_needs?
    return if record.tenancylength.blank?

    min_tenancy_length = 2
    return if record.tenancylength.to_i.between?(min_tenancy_length, 99)

    record.errors.add :needstype, I18n.t("validations.lettings.tenancy.needstype.invalid_fixed_tenancylength", min_tenancy_length:)
    record.errors.add :rent_type, I18n.t("validations.lettings.tenancy.rent_type.invalid_fixed_tenancylength", min_tenancy_length:)
    record.errors.add :tenancylength, :tenancylength_invalid, message: I18n.t("validations.lettings.tenancy.tenancylength.invalid_fixed_tenancylength", min_tenancy_length:)
    record.errors.add :tenancy, I18n.t("validations.lettings.tenancy.tenancy.invalid_fixed_tenancylength", min_tenancy_length:)
  end

  def validate_general_needs_fixed_tenancy_length_intermediate_rent(record)
    return unless record.tenancy_type_fixed_term? && !record.affordable_or_social_rent? && record.is_general_needs?
    return if record.tenancylength.blank?

    min_tenancy_length = 1
    return if record.tenancylength.to_i.between?(min_tenancy_length, 99)

    record.errors.add :needstype, I18n.t("validations.lettings.tenancy.needstype.invalid_fixed_tenancylength", min_tenancy_length:)
    record.errors.add :rent_type, I18n.t("validations.lettings.tenancy.rent_type.invalid_fixed_tenancylength", min_tenancy_length:)
    record.errors.add :tenancylength, :tenancylength_invalid, message: I18n.t("validations.lettings.tenancy.tenancylength.invalid_fixed_tenancylength", min_tenancy_length:)
    record.errors.add :tenancy, I18n.t("validations.lettings.tenancy.tenancy.invalid_fixed_tenancylength", min_tenancy_length:)
  end

  def validate_periodic_tenancy_length(record)
    return unless record.is_periodic_tenancy? && record.tenancylength.present?

    min_tenancy_length = 1
    return if record.tenancylength.to_i.between?(min_tenancy_length, 99)

    record.errors.add :tenancylength, :tenancylength_invalid, message: I18n.t("validations.lettings.tenancy.tenancylength.invalid_periodic_tenancylength", min_tenancy_length:)
    record.errors.add :tenancy, I18n.t("validations.lettings.tenancy.tenancy.invalid_periodic_tenancylength", min_tenancy_length:)
  end

  def validate_tenancy_length_blank_when_not_required(record)
    return if record.tenancylength.blank?
    return if record.tenancy_type_fixed_term? || record.is_periodic_tenancy?

    record.errors.add :tenancylength, :tenancylength_invalid, message: I18n.t("validations.lettings.tenancy.tenancylength.fixed_term_not_required")
    record.errors.add :tenancy, I18n.t("validations.lettings.tenancy.tenancy.fixed_term_not_required")
  end

  def validate_other_tenancy_type(record)
    validate_other_field(record, 3, :tenancy, :tenancyother, "tenancy type", "other tenancy type")
  end

  def validate_joint_tenancy(record)
    return unless record.collection_start_year && record.joint

    if record.hhmemb == 1 && record.joint == 1 && record.collection_start_year >= 2022
      record.errors.add :joint, :not_joint_tenancy, message: I18n.t("validations.lettings.tenancy.joint.sole_tenancy")
      record.errors.add :hhmemb, I18n.t("validations.lettings.tenancy.joint.multiple_members_required")
    end
  end
end
