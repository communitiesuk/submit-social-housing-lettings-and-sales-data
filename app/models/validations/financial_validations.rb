module Validations::FinancialValidations
  include Validations::SharedValidations
  include MoneyFormattingHelper
  include ChargesHelper
  # Validations methods need to be called 'validate_<page_name>' to run on model save
  # or 'validate_' to run on submit as well
  def validate_outstanding_rent_amount(record)
    if !record.has_housing_benefit_rent_shortfall? && record.tshortfall.present?
      record.errors.add :tshortfall, :no_outstanding_charges, message: I18n.t("validations.financial.tshortfall.outstanding_amount_not_expected")
      record.errors.add :hbrentshortfall, :no_outstanding_charges, message: I18n.t("validations.financial.hbrentshortfall.outstanding_amount_not_expected")
    end
  end

  EMPLOYED_STATUSES = [1, 0].freeze
  def validate_net_income_uc_proportion(record)
    (1..8).any? do |n|
      economic_status = record["ecstat#{n}"]
      is_employed = EMPLOYED_STATUSES.include?(economic_status)
      relationship = record["relat#{n}"]
      is_partner_or_main = relationship == "P" || (relationship.nil? && economic_status.present?)
      if is_employed && is_partner_or_main && record.benefits&.zero?
        record.errors.add :benefits, I18n.t("validations.financial.benefits.part_or_full_time")
      end
    end
  end

  def validate_net_income(record)
    if record.ecstat1 && record.hhmemb && record.weekly_net_income && record.startdate && record.form.start_date.year >= 2023
      if record.weekly_net_income > record.applicable_income_range.hard_max
        frequency = record.form.get_question("incfreq", record).label_from_value(record.incfreq).downcase
        hard_max = format_as_currency(record.applicable_income_range.hard_max)
        record.errors.add(
          :earnings,
          :over_hard_max,
          message: I18n.t("validations.financial.earnings.over_hard_max", hard_max:),
        )
        record.errors.add(
          :hhmemb,
          :over_hard_max,
          message: I18n.t("validations.financial.hhmemb.earnings.over_hard_max", earnings: format_as_currency(record.earnings), frequency:),
        )
        (1..record.hhmemb).each do |n|
          record.errors.add(
            "ecstat#{n}",
            :over_hard_max,
            message: I18n.t("validations.financial.ecstat.over_hard_max", earnings: format_as_currency(record.earnings), frequency:),
          )
          next unless record["ecstat#{n}"] == 9

          record.errors.add(
            "age#{n}",
            :over_hard_max,
            message: I18n.t("validations.financial.age.earnings_over_hard_max", earnings: format_as_currency(record.earnings), frequency:),
          )
        end
      end

      if record.weekly_net_income < record.applicable_income_range.hard_min
        hard_min = format_as_currency(record.applicable_income_range.hard_min)
        frequency = record.form.get_question("incfreq", record).label_from_value(record.incfreq).downcase
        record.errors.add(
          :earnings,
          :under_hard_min,
          message: I18n.t("validations.financial.earnings.under_hard_min", hard_min:),
        )
        record.errors.add(
          :hhmemb,
          :under_hard_min,
          message: I18n.t("validations.financial.hhmemb.earnings.under_hard_min", earnings: format_as_currency(record.earnings), frequency:),
        )
        (1..record.hhmemb).each do |n|
          record.errors.add(
            "ecstat#{n}",
            :under_hard_min,
            message: I18n.t("validations.financial.ecstat.under_hard_min", earnings: format_as_currency(record.earnings), frequency:),
          )
          # N.B. It is not possible for a change to an age field to increase the hard min
        end
      end
    end

    if record.earnings.present? && record.incfreq.blank?
      record.errors.add :incfreq, I18n.t("validations.financial.earnings.freq_missing")
      record.errors.add :earnings, I18n.t("validations.financial.earnings.freq_missing")
    end

    if record.incfreq.present? && record.earnings.blank?
      record.errors.add :earnings, I18n.t("validations.financial.earnings.earnings_missing")
      record.errors.add :incfreq, I18n.t("validations.financial.earnings.earnings_missing")
    end
  end

  def validate_negative_currency(record)
    t = %w[earnings brent scharge pscharge supcharg]
    t.each do |x|
      if record[x].present? && record[x].negative?
        record.errors.add x.to_sym, I18n.t("validations.financial.negative_currency")
      end
    end
  end

  def validate_tshortfall(record)
    if record.has_housing_benefit_rent_shortfall? && no_known_benefits?(record)
      record.errors.add :tshortfall, I18n.t("validations.financial.hbrentshortfall.outstanding_no_benefits")
    end
  end

  def no_known_benefits?(record)
    return true unless record.collection_start_year

    if record.collection_start_year <= 2021
      record.benefits_unknown? ||
        record.receives_no_benefits? ||
        record.receives_universal_credit_but_no_housing_benefit?
    else
      record.benefits_unknown? ||
        record.receives_no_benefits? ||
        record.tenant_refuses_to_say_benefits?
    end
  end

  def validate_rent_amount(record)
    if record.wtshortfall
      if record.is_supported_housing? && record.wchchrg && (record.wtshortfall > record.wchchrg)
        record.errors.add :tshortfall, message: I18n.t("validations.financial.tshortfall.more_than_carehome_charge")
        record.errors.add :chcharge, I18n.t("validations.financial.carehome.less_than_shortfall")
      end

      if record.wtcharge && (record.wtshortfall > record.wtcharge)
        record.errors.add :tshortfall, :more_than_rent, message: I18n.t("validations.financial.tshortfall.more_than_total_charge")
        record.errors.add :tcharge, I18n.t("validations.financial.tcharge.less_than_shortfall")
      elsif record.wtshortfall < 0.01
        record.errors.add :tshortfall, :must_be_positive, message: I18n.t("validations.financial.tshortfall.must_be_positive")
      end
    end

    if record.tcharge.present? && weekly_value_in_range(record, "tcharge", 0, 9.99)
      record.errors.add :tcharge, :under_10, message: I18n.t("validations.financial.tcharge.under_10")
    end

    answered_questions = [record.tcharge, record.chcharge].concat(record.household_charge && record.household_charge == 1 ? [record.household_charge] : [])
    if answered_questions.count(&:present?) > 1
      record.errors.add :tcharge, :complete_1_of_3, message: I18n.t("validations.financial.charges.complete_1_of_3") if record.tcharge.present?
      record.errors.add :chcharge, I18n.t("validations.financial.charges.complete_1_of_3") if record.chcharge.present?
      record.errors.add :household_charge, I18n.t("validations.financial.charges.complete_1_of_3") if record.household_charge.present?
    end

    validate_charges(record)
    validate_rent_range(record)
  end

  def validate_rent_period(record)
    return unless record.managing_organisation && record.period

    unless record.managing_organisation.rent_periods.include? record.period
      record.errors.add :period, :wrong_rent_period, message: I18n.t(
        "validations.financial.rent_period.invalid_for_org.period",
        org_name: record.managing_organisation.name,
        rent_period: record.form.get_question("period", record).label_from_value(record.period).downcase,
      )
      record.errors.add :managing_organisation_id, :skip_bu_error, message: I18n.t(
        "validations.financial.rent_period.invalid_for_org.managing_org",
        org_name: record.managing_organisation.name,
        rent_period: record.form.get_question("period", record).label_from_value(record.period).downcase,
      )
    end
  end

  def validate_care_home_charges(record)
    if record.is_carehome?
      period = record.form.get_question("period", record).label_from_value(record.period).downcase
      # NOTE: This is a temporary change to allow `ccharge` values despite `is_carehome` being true. This value
      # is going to be moved to a soft validation in CLDC-2074, so we can safely do this.
      if record.chcharge.blank?
        # record.errors.add :is_carehome, I18n.t("validations.financial.carehome.not_provided", period:)
        # record.errors.add :chcharge, I18n.t("validations.financial.carehome.not_provided", period:)
      elsif !weekly_value_in_range(record, "chcharge", 10, 5000)
        max_chcharge = record.weekly_to_value_per_period(5000)
        min_chcharge = record.weekly_to_value_per_period(10)
        message = I18n.t("validations.financial.carehome.out_of_range", period:, min_chcharge:, max_chcharge:)

        record.errors.add :period, message
        record.errors.add :chcharge, :out_of_range, message:
      end
    end
  end

private

  def validate_charges(record)
    return unless record.owning_organisation

    provider_type = record.owning_organisation.provider_type_before_type_cast
    %i[scharge pscharge supcharg].each do |charge|
      maximum_per_week = CHARGE_MAXIMA_PER_WEEK.dig(charge, PROVIDER_TYPE[provider_type], NEEDSTYPE_VALUES[record.needstype])

      next unless maximum_per_week.present? && record[:period].present? && record[charge].present? && !weekly_value_in_range(record, charge, 0.0, maximum_per_week)

      charge_name = CHARGE_NAMES[charge]
      frequency = record.form.get_question("period", record).label_from_value(record.period).downcase
      letting_type = NEEDSTYPE_VALUES[record.needstype].to_s.humanize(capitalize: false)
      provider_type_label = PROVIDER_TYPE[provider_type].to_s.humanize(capitalize: false)
      maximum_per_period = record.weekly_to_value_per_period(maximum_per_week)

      record.errors.add charge, :outside_the_range, message: I18n.t("validations.financial.rent.out_of_range", charge_name:, maximum_per_period:, frequency:, letting_type:, provider_type: provider_type_label)
      record.errors.add :period, :outside_the_range, message: I18n.t("validations.financial.rent.out_of_range", charge_name:, maximum_per_period:, frequency:, letting_type:, provider_type: provider_type_label)
    end
  end

  def weekly_value_in_range(record, field, min, max)
    record.weekly_value(record[field])&.between?(min, max)
  end

  def validate_rent_range(record)
    return if record.startdate.blank?

    collection_year = record.collection_start_year

    rent_range = LaRentRange.find_by(
      start_year: collection_year,
      la: record.la,
      beds: record.beds_for_la_rent_range,
      lettype: record.lettype,
    )

    if rent_range.present? && !weekly_value_in_range(record, "brent", rent_range.hard_min, rent_range.hard_max) && record.brent.present? && record.period.present?
      if record.weekly_value(record["brent"]) < rent_range.hard_min
        record.errors.add :brent, :below_hard_min, message: I18n.t("validations.financial.brent.below_hard_min")
        record.errors.add :beds, I18n.t("validations.financial.brent.beds.below_hard_min")
        record.errors.add :uprn, I18n.t("validations.financial.brent.uprn.below_hard_min")
        record.errors.add :la, I18n.t("validations.financial.brent.la.below_hard_min")
        record.errors.add :postcode_known, I18n.t("validations.financial.brent.postcode_known.below_hard_min")
        record.errors.add :scheme_id, I18n.t("validations.financial.brent.scheme_id.below_hard_min")
        record.errors.add :location_id, I18n.t("validations.financial.brent.location_id.below_hard_min")
        record.errors.add :rent_type, I18n.t("validations.financial.brent.rent_type.below_hard_min")
        record.errors.add :needstype, I18n.t("validations.financial.brent.needstype.below_hard_min")
        record.errors.add :period, I18n.t("validations.financial.brent.period.below_hard_min")
      end

      if record.weekly_value(record["brent"]) > rent_range.hard_max
        record.errors.add :brent, :over_hard_max, message: I18n.t("validations.financial.brent.above_hard_max")
        record.errors.add :beds, I18n.t("validations.financial.brent.beds.above_hard_max")
        record.errors.add :uprn, I18n.t("validations.financial.brent.uprn.above_hard_max")
        record.errors.add :la, I18n.t("validations.financial.brent.la.above_hard_max")
        record.errors.add :postcode_known, I18n.t("validations.financial.brent.postcode_known.above_hard_max")
        record.errors.add :scheme_id, I18n.t("validations.financial.brent.scheme_id.above_hard_max")
        record.errors.add :location_id, I18n.t("validations.financial.brent.location_id.above_hard_max")
        record.errors.add :rent_type, I18n.t("validations.financial.brent.rent_type.above_hard_max")
        record.errors.add :needstype, I18n.t("validations.financial.brent.needstype.above_hard_max")
        record.errors.add :period, I18n.t("validations.financial.brent.period.above_hard_max")
      end
    end
  end
end
