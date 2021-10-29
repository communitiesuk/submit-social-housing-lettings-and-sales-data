module FinancialValidations
  # Validations methods need to be called 'validate_' to run on model save
  def validate_outstanding_rent_amount(record)
    if record.outstanding_rent_or_charges == "Yes" && record.outstanding_amount.blank?
      record.errors.add :outstanding_amount, "You must answer the oustanding amout question if you have outstanding rent or charges."
    end
    if record.outstanding_rent_or_charges == "No" && record.outstanding_amount.present?
      record.errors.add :outstanding_amount, "You must not answer the oustanding amout question if you don't have outstanding rent or charges."
    end
  end

  EMPLOYED_STATUSES = ["Full-time - 30 hours or more", "Part-time - Less than 30 hours"].freeze
  def validate_net_income_uc_proportion(record)
    (1..8).any? do |n|
      economic_status = record["person_#{n}_economic_status"]
      is_employed = EMPLOYED_STATUSES.include?(economic_status)
      relationship = record["person_#{n}_relationship"]
      is_partner_or_main = relationship == "Partner" || (relationship.nil? && economic_status.present?)
      if is_employed && is_partner_or_main && record.net_income_uc_proportion == "All"
        record.errors.add :net_income_uc_proportion, "income is from Universal Credit, state pensions or benefits cannot be All if the tenant or the partner works part or full time"
      end
    end
  end

  def validate_net_income(record)
    return unless record.person_1_economic_status && record.weekly_net_income

    if record.weekly_net_income > record.applicable_income_range.hard_max
      record.errors.add :net_income, "Net income cannot be greater than #{record.applicable_income_range.hard_max} given the tenant's working situation"
    end

    if record.weekly_net_income < record.applicable_income_range.hard_min
      record.errors.add :net_income, "Net income cannot be less than #{record.applicable_income_range.hard_min} given the tenant's working situation"
    end
  end
end
