module Validations::PropertyValidations
  # Validations methods need to be called 'validate_<page_name>' to run on model save
  # or 'validate_' to run on submit as well
  include Constants::CaseLog

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
end
