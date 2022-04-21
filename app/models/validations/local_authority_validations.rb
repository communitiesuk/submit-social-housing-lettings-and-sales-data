module Validations::LocalAuthorityValidations
  POSTCODE_REGEXP = Validations::PropertyValidations::POSTCODE_REGEXP

  def validate_previous_accommodation_postcode(record)
    postcode = record.ppostcode_full
    if record.previous_postcode_known? && (postcode.blank? || !postcode.match(POSTCODE_REGEXP))
      error_message = I18n.t("validations.postcode")
      record.errors.add :ppostcode_full, error_message
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
      if record.postcode_known? && record.postcode_full.present?
        record.errors.add :postcode_full, I18n.t("validations.property.la.london_rent_postcode")
      end
    end

    if record.la_known? && record.la.blank?
      record.errors.add :la, I18n.t("validations.property.la.la_known")
    end
  end
end
