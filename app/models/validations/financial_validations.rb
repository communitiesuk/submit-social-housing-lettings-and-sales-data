module Validations::FinancialValidations
  # Validations methods need to be called 'validate_<page_name>' to run on model save
  # or 'validate_' to run on submit as well
  def validate_outstanding_rent_amount(record)
    if record.hbrentshortfall == "Yes" && record.tshortfall.blank?
      record.errors.add :tshortfall, I18n.t("validations.financial.tshortfall.outstanding_amount_required")
    end
    if record.hbrentshortfall == "No" && record.tshortfall.present?
      record.errors.add :tshortfall, I18n.t("validations.financial.tshortfall.outstanding_amount_not_required")
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
        record.errors.add :benefits, I18n.t("validations.financial.benefits.part_or_full_time")
      end
    end
  end

  def validate_net_income(record)
    return unless record.ecstat1 && record.weekly_net_income

    if record.weekly_net_income > record.applicable_income_range.hard_max
      record.errors.add :earnings, I18n.t("validations.financial.earnings.under_hard_max", hard_max: record.applicable_income_range.hard_max)
    end

    if record.weekly_net_income < record.applicable_income_range.hard_min
      record.errors.add :earnings, I18n.t("validations.financial.earnings.over_hard_min", hard_min: record.applicable_income_range.hard_min)
    end
  end

  def validate_hbrentshortfall(record)
    is_present = record.hbrentshortfall.present?
    is_yes = record.hbrentshortfall == "Yes"
    hb_donotknow = record.hb == "Don’t know"
    hb_no_hb_or_uc = record.hb == "Not Housing Benefit or Universal Credit"
    hb_uc_no_hb = record.hb == "Universal Credit without housing element and no Housing Benefit"
    hb_no_uc = record.hb == "Housing Benefit, but not Universal Credit"
    hb_uc_no_he_hb = record.hb == "Universal Credit with housing element, but not Housing Benefit"
    hb_and_uc = record.hb == "Universal Credit and Housing Benefit"

    conditions = [
      { condition: is_yes && (hb_donotknow || hb_no_hb_or_uc || hb_uc_no_hb), error: I18n.t("validations.financial.hbrentshortfall.outstanding_no_benefits") },
      { condition: (hb_no_uc || hb_uc_no_he_hb || hb_and_uc) && !is_present, error: I18n.t("validations.financial.hbrentshortfall.amount_required") },
    ]

    conditions.each { |condition| condition[:condition] ? (record.errors.add :hbrentshortfall, condition[:error]) : nil }
  end
end
