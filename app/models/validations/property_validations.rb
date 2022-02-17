module Validations::PropertyValidations
  # Validations methods need to be called 'validate_<page_name>' to run on model save
  # or 'validate_' to run on submit as well
  include Constants::CaseLog

  POSTCODE_REGEXP = /^(([A-Z]{1,2}[0-9][A-Z0-9]?|ASCN|STHL|TDCU|BBND|[BFS]IQQ|PCRN|TKCA) ?[0-9][A-Z]{2}|BFPO ?[0-9]{1,4}|(KY[0-9]|MSR|VG|AI)[ -]?[0-9]{4}|[A-Z]{2} ?[0-9]{2}|GE ?CX|GIR ?0A{2}|SAN ?TA1)$/i

  def validate_property_number_of_times_relet(record)
    return unless record.offered

    # Since offered is an integer type ActiveRecord will automatically cast that for us
    # but it's type casting is a little lax so "random" becomes 0. To make sure that doesn't pass
    # validation and then get silently dropped we attempt strict type casting on the original value
    # as part of our validation.
    begin
      Integer(record.offered_before_type_cast)
    rescue ArgumentError
      record.errors.add :offered, I18n.t("validations.property.offered.relet_number")
    end

    if record.offered.negative? || record.offered > 20
      record.errors.add :offered, I18n.t("validations.property.offered.relet_number")
    end
  end

  def validate_la(record)
    if record.la.present? && !LONDON_BOROUGHS.include?(record.la) && (record.rent_type == "London Affordable rent" || record.rent_type == "London living rent")
      record.errors.add :la, I18n.t("validations.property.la.london_rent")
    end
  end

  FIRST_LET_VACANCY_REASONS = ["First let of new-build property",
                               "First let of conversion, rehabilitation or acquired property",
                               "First let of leased property"].freeze
  def validate_rsnvac(record)
    if !record.first_time_property_let_as_social_housing? && FIRST_LET_VACANCY_REASONS.include?(record.rsnvac)
      record.errors.add :rsnvac, I18n.t("validations.property.rsnvac.first_let_not_social")
    end

    if record.first_time_property_let_as_social_housing? && record.rsnvac.present? && !FIRST_LET_VACANCY_REASONS.include?(record.rsnvac)
      record.errors.add :rsnvac, I18n.t("validations.property.rsnvac.first_let_social")
    end

    if record.rsnvac == "Re-let to tenant who occupied same property as temporary accommodation" && NON_TEMP_ACCOMMODATION.include?(record.prevten)
      record.errors.add :rsnvac, I18n.t("validations.property.rsnvac.non_temp_accommodation")
    end

    if record.rsnvac == "Re-let to tenant who occupied same property as temporary accommodation" && REFERRAL_INVALID_TMP.include?(record.referral)
      record.errors.add :rsnvac, I18n.t("validations.property.rsnvac.referral_invalid")
    end
  end

  def validate_unitletas(record)
    if record.first_time_property_let_as_social_housing? && record.unitletas.present?
      record.errors.add :unitletas, I18n.t("validations.property.rsnvac.previous_let_social")
    end
  end

  def validate_property_postcode(record)
    postcode = record.property_postcode
    if record.postcode_known == "Yes" && (postcode.blank? || !postcode.match(POSTCODE_REGEXP))
      error_message = I18n.t("validations.postcode")
      record.errors.add :property_postcode, error_message
    end
  end

  def validate_shared_housing_rooms(record)
    unless record.unittype_gn.nil?
      if record.unittype_gn == "Bedsit" && record.beds != 1 && record.beds.present?
        record.errors.add :unittype_gn, I18n.t("validations.property.unittype_gn.one_bedroom_bedsit")
      end

      if record.other_hhmemb&.zero? && record.unittype_gn.include?("Shared") &&
          !record.beds.to_i.between?(1, 3) && record.beds.present?
        record.errors.add :unittype_gn, I18n.t("validations.property.unittype_gn.one_three_bedroom_single_tenant_shared")
      elsif record.unittype_gn.include?("Shared") && record.beds.present? && !record.beds.to_i.between?(1, 7)
        record.errors.add :unittype_gn, I18n.t("validations.property.unittype_gn.one_seven_bedroom_shared")
      end
    end
  end
end
