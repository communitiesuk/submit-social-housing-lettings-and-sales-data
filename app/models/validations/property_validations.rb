module Validations::PropertyValidations
  # Validations methods need to be called 'validate_<page_name>' to run on model save
  # or 'validate_' to run on submit as well
  include Constants::CaseLog

  POSTCODE_REGEXP = /^(([A-Z]{1,2}[0-9][A-Z0-9]?|ASCN|STHL|TDCU|BBND|[BFS]IQQ|PCRN|TKCA) ?[0-9][A-Z]{2}|BFPO ?[0-9]{1,4}|(KY[0-9]|MSR|VG|AI)[ -]?[0-9]{4}|[A-Z]{2} ?[0-9]{2}|GE ?CX|GIR ?0A{2}|SAN ?TA1)$/i

  def validate_property_number_of_times_relet(record)
    if record.offered && !/^[1-9]$|^0[1-9]$|^1[0-9]$|^20$/.match?(record.offered.to_s)
      record.errors.add :offered, "Property number of times relet must be between 0 and 20"
    end
  end

  def validate_la(record)
    if record.la.present? && !LONDON_BOROUGHS.include?(record.la) && (record.rent_type == "London Affordable rent" || record.rent_type == "London living rent")
      record.errors.add :la, "Local authority has to be in London"
    end
  end

  FIRST_LET_VACANCY_REASONS = ["First let of new-build property",
                               "First let of conversion, rehabilitation or acquired property",
                               "First let of leased property"].freeze
  def validate_rsnvac(record)
    if !record.first_time_property_let_as_social_housing? && FIRST_LET_VACANCY_REASONS.include?(record.rsnvac)
      record.errors.add :rsnvac, "Reason for vacancy cannot be first let if unit has been previously let as social housing"
    end

    if record.first_time_property_let_as_social_housing? && record.rsnvac.present? && !FIRST_LET_VACANCY_REASONS.include?(record.rsnvac)
      record.errors.add :rsnvac, "Reason for vacancy must be first let if unit has been previously let as social housing"
    end
  end

  def validate_unitletas(record)
    if record.first_time_property_let_as_social_housing? && record.unitletas.present?
      record.errors.add :unitletas, "Property cannot have a previous let type if it is being let as social housing for the first time"
    end
  end

  def validate_property_postcode(record)
    postcode = record.property_postcode
    if record.postcode_known == "Yes" && (postcode.blank? || !postcode.match(POSTCODE_REGEXP))
      error_message = "Enter a postcode in the correct format, for example AA1 1AA"
      record.errors.add :property_postcode, error_message
    end
  end
end
