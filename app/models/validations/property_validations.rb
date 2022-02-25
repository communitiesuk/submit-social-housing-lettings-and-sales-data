module Validations::PropertyValidations
  # Validations methods need to be called 'validate_<page_name>' to run on model save
  # or 'validate_' to run on submit as well
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

  LONDON_BOROUGHS = %w[E09000001
                       E09000002
                       E09000003
                       E09000004
                       E09000005
                       E09000006
                       E09000007
                       E09000008
                       E09000009
                       E09000010
                       E09000011
                       E09000012
                       E09000013
                       E09000014
                       E09000015
                       E09000016
                       E09000017
                       E09000018
                       E09000019
                       E09000020
                       E09000021
                       E09000022
                       E09000023
                       E09000024
                       E09000025
                       E09000026
                       E09000027
                       E09000028
                       E09000029
                       E09000030
                       E09000031
                       E09000032
                       E09000033].freeze
  def validate_la(record)
    if record.la.present? && !LONDON_BOROUGHS.include?(record.la) && record.is_london_rent?
      record.errors.add :la, I18n.t("validations.property.la.london_rent")
    end

    if record.la_known? && record.la.blank?
      record.errors.add :la, I18n.t("validations.property.la.la_known")
    end
  end

  REFERRAL_INVALID_TMP = [2, 3, 5, 6, 7, 8].freeze
  def validate_rsnvac(record)
    if !record.first_time_property_let_as_social_housing? && record.has_first_let_vacancy_reason?
      record.errors.add :rsnvac, I18n.t("validations.property.rsnvac.first_let_not_social")
    end

    if record.first_time_property_let_as_social_housing? && record.rsnvac.present? && !record.has_first_let_vacancy_reason?
      record.errors.add :rsnvac, I18n.t("validations.property.rsnvac.first_let_social")
    end

    if record.is_relet_to_temp_tenant? && !record.previous_tenancy_was_temporary?
      record.errors.add :rsnvac, I18n.t("validations.property.rsnvac.non_temp_accommodation")
    end

    if record.is_relet_to_temp_tenant? && REFERRAL_INVALID_TMP.include?(record.referral)
      record.errors.add :rsnvac, I18n.t("validations.property.rsnvac.referral_invalid")
      record.errors.add :referral, I18n.t("validations.household.referral.rsnvac_non_temp")
    end
  end

  def validate_unitletas(record)
    if record.first_time_property_let_as_social_housing? && record.unitletas.present?
      record.errors.add :unitletas, I18n.t("validations.property.rsnvac.previous_let_social")
    end
  end

  def validate_property_postcode(record)
    postcode = record.property_postcode
    if record.postcode_known? && (postcode.blank? || !postcode.match(POSTCODE_REGEXP))
      error_message = I18n.t("validations.postcode")
      record.errors.add :property_postcode, error_message
    end
  end

  def validate_shared_housing_rooms(record)
    if record.beds.present? && record.beds.negative?
      record.errors.add :beds, I18n.t("validations.property.beds.negative")
    end

    unless record.unittype_gn.nil?
      if record.is_bedsit? && record.beds != 1 && record.beds.present?
        record.errors.add :unittype_gn, I18n.t("validations.property.unittype_gn.one_bedroom_bedsit")
        record.errors.add :beds, I18n.t("validations.property.unittype_gn.one_bedroom_bedsit")
      end

      if record.other_hhmemb&.zero? && record.is_shared_housing? &&
          !record.beds.to_i.between?(1, 3) && record.beds.present?
        record.errors.add :unittype_gn, I18n.t("validations.property.unittype_gn.one_three_bedroom_single_tenant_shared")
        record.errors.add :beds, I18n.t("validations.property.unittype_gn.one_three_bedroom_single_tenant_shared")
      elsif record.is_shared_housing? && record.beds.present? && !record.beds.to_i.between?(1, 7)
        record.errors.add :unittype_gn, I18n.t("validations.property.unittype_gn.one_seven_bedroom_shared")
        record.errors.add :beds, I18n.t("validations.property.unittype_gn.one_seven_bedroom_shared")
      end
    end
  end
end
