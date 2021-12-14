module Validations::FinancialValidations
  # Validations methods need to be called 'validate_<page_name>' to run on model save
  # or 'validate_' to run on submit as well
  def validate_outstanding_rent_amount(record)
    if record.hbrentshortfall == "Yes" && record.tshortfall.blank?
      record.errors.add :tshortfall, "You must answer the oustanding amout question if you have outstanding rent or charges."
    end
    if record.hbrentshortfall == "No" && record.tshortfall.present?
      record.errors.add :tshortfall, "You must not answer the oustanding amout question if you don't have outstanding rent or charges."
    end
  end

  EMPLOYED_STATUSES = ["Full-time - 30 hours or more", "Part-time - Less than 30 hours"].freeze
  def validate_net_income_uc_proportion(record)
    (1..8).any? do |n|
      economic_status = record["ecstat#{n}"]
      is_employed = EMPLOYED_STATUSES.include?(economic_status)
      relationship = record["relat#{n}"]
      is_partner_or_main = relationship == "Partner" || (relationship.nil? && economic_status.present?)
      if is_employed && is_partner_or_main && record.benefits == "All"
        record.errors.add :benefits, "income is from Universal Credit, state pensions or benefits cannot be All if the tenant or the partner works part or full time"
      end
    end
  end

  def validate_net_income(record)
    return unless record.ecstat1 && record.weekly_net_income

    if record.weekly_net_income > record.applicable_income_range.hard_max
      record.errors.add :earnings, "Net income cannot be greater than #{record.applicable_income_range.hard_max} given the tenant's working situation"
    end

    if record.weekly_net_income < record.applicable_income_range.hard_min
      record.errors.add :earnings, "Net income cannot be less than #{record.applicable_income_range.hard_min} given the tenant's working situation"
    end
  end

  def validate_hbrentshortfall(record)
    is_present = record.hbrentshortfall.present?
    is_yes = record.hbrentshortfall == "Yes"
    hb_donotknow = record.hb == "Do not know"
    hb_no_hb_or_uc = record.hb == "Not Housing Benefit or Universal Credit"
    hb_uc_no_hb = record.hb == "Universal Credit without housing element and no Housing Benefit"
    hb_no_uc = record.hb == "Housing Benefit, but not Universal Credit"
    hb_uc_no_he_hb = record.hb == "Universal Credit with housing element, but not Housing Benefit"
    hb_and_uc = record.hb == "Universal Credit and Housing Benefit"

    conditions = [
      { condition: is_yes && (hb_donotknow || hb_no_hb_or_uc || hb_uc_no_hb), error: "Outstanding amount for basic rent and/or benefit eligible charges can not be 'Yes' if tenant is not in receipt of housing benefit or universal benefit or if benefit is unknown" },
      { condition: (hb_no_uc || hb_uc_no_he_hb || hb_and_uc) && !is_present, error: "Must be completed if Universal credit and/or Housing Benefit received" },
    ]

    conditions.each { |condition| condition[:condition] ? (record.errors.add :hbrentshortfall, condition[:error]) : nil }
  end
end
