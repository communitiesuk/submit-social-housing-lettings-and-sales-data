module Validations::LocalAuthorityValidations
  include Constants::CaseLog
  POSTCODE_REGEXP = Validations::PropertyValidations::POSTCODE_REGEXP

  def validate_previous_accommodation_postcode(record)
    postcode = record.previous_postcode
    if record.previous_postcode_known == "Yes" && (postcode.blank? || !postcode.match(POSTCODE_REGEXP))
      error_message = I18n.t("validations.postcode")
      record.errors.add :previous_postcode, error_message
    end
  end

  def validate_referral(record)
    if record.rsnvac == "Relet to tenant who occupied same property as temporary accommodation" && REFERRAL_INVALID_TMP.include?(record.referral)
      record.errors.add :referral, I18n.t("validations.local_authority.referral.rsnvac_non_temp")
    end
  end
end
