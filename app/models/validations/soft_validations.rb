module Validations::SoftValidations
  include ChargesHelper

  ALLOWED_INCOME_RANGES = {
    1 => OpenStruct.new(soft_min: 143, soft_max: 730, hard_min: 90, hard_max: 1230),
    2 => OpenStruct.new(soft_min: 67, soft_max: 620, hard_min: 50, hard_max: 950),
    3 => OpenStruct.new(soft_min: 80, soft_max: 480, hard_min: 40, hard_max: 990),
    4 => OpenStruct.new(soft_min: 50, soft_max: 370, hard_min: 10, hard_max: 450),
    5 => OpenStruct.new(soft_min: 50, soft_max: 380, hard_min: 10, hard_max: 1000),
    6 => OpenStruct.new(soft_min: 53, soft_max: 540, hard_min: 10, hard_max: 890),
    7 => OpenStruct.new(soft_min: 47, soft_max: 460, hard_min: 10, hard_max: 1300),
    8 => OpenStruct.new(soft_min: 54, soft_max: 460, hard_min: 10, hard_max: 2000),
    9 => OpenStruct.new(soft_min: 50, soft_max: 450, hard_min: 10, hard_max: 750),
    0 => OpenStruct.new(soft_min: 50, soft_max: 580, hard_min: 10, hard_max: 1040),
    10 => OpenStruct.new(soft_min: 47, soft_max: 730, hard_min: 10, hard_max: 2000),
  }.freeze

  def net_income_in_soft_max_range?
    return unless weekly_net_income && ecstat1 && hhmemb && applicable_income_range

    weekly_net_income.between?(applicable_income_range.soft_max, applicable_income_range.hard_max)
  end

  def net_income_in_soft_min_range?
    return unless weekly_net_income && ecstat1 && hhmemb && applicable_income_range

    weekly_net_income.between?(applicable_income_range.hard_min, applicable_income_range.soft_min)
  end

  def rent_soft_validation_triggered?
    rent_in_soft_min_range? || rent_in_soft_max_range?
  end

  def rent_soft_validation_higher_or_lower_text
    rent_in_soft_min_range? ? "lower" : "higher"
  end

  def rent_in_soft_min_range?
    return unless brent && weekly_value(brent) && startdate

    rent_range = LaRentRange.find_by(
      start_year: collection_start_year,
      la:,
      beds: beds_for_la_rent_range,
      lettype: get_lettype,
    )
    rent_range.present? && weekly_value(brent).between?(rent_range.hard_min, rent_range.soft_min)
  end

  def rent_in_soft_max_range?
    return unless brent && weekly_value(brent) && startdate

    rent_range = LaRentRange.find_by(
      start_year: collection_start_year,
      la:,
      beds: beds_for_la_rent_range,
      lettype: get_lettype,
    )
    if beds.present? && rent_range.present? && beds > LaRentRange::MAX_BEDS
      weekly_value(brent) > rent_range.soft_max
    elsif rent_range.present?
      weekly_value(brent).between?(rent_range.soft_max, rent_range.hard_max)
    end
  end

  (1..8).each do |person_num|
    define_method("person_#{person_num}_retired_under_soft_min_age?") do
      retired_under_soft_min_age?(person_num)
    end
    define_method("person_#{person_num}_not_retired_over_soft_max_age?") do
      not_retired_over_soft_max_age?(person_num)
    end
    define_method("person_#{person_num}_partner_under_16?") do
      partner_under_16?(person_num)
    end
  end

  def all_male_tenants_in_a_pregnant_household?
    all_male_tenants_in_the_household? && all_tenants_gender_information_completed? && preg_occ == 1
  end

  def female_in_pregnant_household_in_soft_validation_range?
    all_tenants_age_and_gender_information_completed? && females_in_the_household? && !females_in_age_range(16, 50) && preg_occ == 1
  end

  def all_tenants_age_and_gender_information_completed?
    return false if hhmemb.present? && hhmemb > 8

    person_count = hhmemb || 8

    (1..person_count).all? do |n|
      public_send("sex#{n}").present? && public_send("age#{n}").present? && details_known_or_lead_tenant?(n) && public_send("age#{n}_known").present? && public_send("age#{n}_known").zero?
    end
  end

  def all_tenants_gender_information_completed?
    person_count = hhmemb || 8

    (1..person_count).all? do |n|
      public_send("sex#{n}").present? && details_known_or_lead_tenant?(n)
    end
  end

  TWO_YEARS_IN_DAYS = 730
  TEN_YEARS_IN_DAYS = 3650
  TWENTY_YEARS_IN_DAYS = 7300

  def major_repairs_date_in_soft_range?
    upper_limit = form.start_year_2025_or_later? ? TWENTY_YEARS_IN_DAYS : TEN_YEARS_IN_DAYS
    mrcdate.present? && startdate.present? && mrcdate.between?(startdate.to_date - upper_limit, startdate.to_date - TWO_YEARS_IN_DAYS)
  end

  def voiddate_in_soft_range?
    upper_limit = form.start_year_2025_or_later? ? TWENTY_YEARS_IN_DAYS : TEN_YEARS_IN_DAYS
    voiddate.present? && startdate.present? && voiddate.between?(startdate.to_date - upper_limit, startdate.to_date - TWO_YEARS_IN_DAYS)
  end

  def net_income_higher_or_lower_text
    net_income_in_soft_max_range? ? "higher" : "lower"
  end

  def scharge_in_soft_max_range?
    return unless scharge && period && needstype && owning_organisation
    return if weekly_value(scharge).blank?

    soft_max = if needstype == 1
                 owning_organisation.provider_type == "LA" ? 25 : 35
               else
                 owning_organisation.provider_type == "LA" ? 100 : 200
               end

    provider_type = owning_organisation.provider_type_before_type_cast
    hard_max = CHARGE_MAXIMA_PER_WEEK.dig(:scharge, PROVIDER_TYPE[provider_type], NEEDSTYPE_VALUES[needstype])

    weekly_scharge = weekly_value(scharge)
    weekly_scharge > soft_max && weekly_scharge <= hard_max
  end

  def pscharge_in_soft_max_range?
    return unless pscharge && period && needstype && owning_organisation
    return if weekly_value(pscharge).blank?

    soft_max = if needstype == 1
                 owning_organisation.provider_type == "LA" ? 25 : 35
               else
                 owning_organisation.provider_type == "LA" ? 75 : 100
               end

    provider_type = owning_organisation.provider_type_before_type_cast
    hard_max = CHARGE_MAXIMA_PER_WEEK.dig(:pscharge, PROVIDER_TYPE[provider_type], NEEDSTYPE_VALUES[needstype])

    weekly_pscharge = weekly_value(pscharge)
    weekly_pscharge > soft_max && weekly_pscharge <= hard_max
  end

  def supcharg_in_soft_max_range?
    return unless supcharg && period && needstype && owning_organisation
    return if weekly_value(supcharg).blank?

    soft_max = if needstype == 1
                 owning_organisation.provider_type == "LA" ? 25 : 35
               else
                 owning_organisation.provider_type == "LA" ? 75 : 85
               end

    provider_type = owning_organisation.provider_type_before_type_cast
    hard_max = CHARGE_MAXIMA_PER_WEEK.dig(:supcharg, PROVIDER_TYPE[provider_type], NEEDSTYPE_VALUES[needstype])

    weekly_supcharg = weekly_value(supcharg)
    weekly_supcharg > soft_max && weekly_supcharg <= hard_max
  end

  PHRASES_LIKELY_TO_INDICATE_EXISTING_REASON_CATEGORY = [
    "Decant",
    "Decanted",
    "Refugee",
    "Asylum",
    "Ukraine",
    "Ukrainian",
    "Army",
    "Military",
    "Domestic Abuse",
    "Domestic Violence",
    "DA",
    "DV",
    "Relationship breakdown",
    "Overcrowding",
    "Overcrowded",
    "Too small",
    "More space",
    "Bigger property",
    "Damp",
    "Mould",
    "Fire",
    "Repossession",
    "Death",
    "Deceased",
    "Passed away",
    "Prison",
    "Hospital",
  ].freeze

  PHRASES_LIKELY_TO_INDICATE_EXISTING_REASON_CATEGORY_REGEX = Regexp.union(
    PHRASES_LIKELY_TO_INDICATE_EXISTING_REASON_CATEGORY.map { |phrase| Regexp.new("\\b[^[:alpha]]*#{phrase}[^[:alpha:]]*\\b", Regexp::IGNORECASE) },
  )

  def reasonother_might_be_existing_category?
    PHRASES_LIKELY_TO_INDICATE_EXISTING_REASON_CATEGORY_REGEX.match?(reasonother)
  end

  def multiple_partners?
    return unless hhmemb

    max_person_with_details = sales? ? [hhmemb, 6].min : [hhmemb, 8].min
    (2..max_person_with_details).many? { |n| public_send("relat#{n}") == "P" }
  end

  def at_least_one_working_situation_is_sickness_and_household_sickness_is_no?
    at_least_one_person_working_situation_is_illness? && no_one_in_household_with_illness?
  end

private

  def details_known_or_lead_tenant?(tenant_number)
    return true if tenant_number == 1

    public_send("details_known_#{tenant_number}").zero?
  end

  def females_in_age_range(min, max)
    person_count = hhmemb || 8

    (1..person_count).any? do |n|
      public_send("sex#{n}") == "F" && public_send("age#{n}").present? && public_send("age#{n}").between?(min, max)
    end
  end

  def females_in_the_household?
    person_count = hhmemb || 8

    (1..person_count).any? do |n|
      public_send("sex#{n}") == "F" || public_send("sex#{n}").nil?
    end
  end

  def all_male_tenants_in_the_household?
    return false if hhmemb.present? && hhmemb > 8

    person_count = hhmemb || 8

    (1..person_count).all? do |n|
      public_send("sex#{n}") == "M"
    end
  end

  def tenant_is_retired?(economic_status)
    economic_status == 5
  end

  def tenant_prefers_not_to_say?(economic_status)
    economic_status == 10
  end

  def retired_under_soft_min_age?(person_num)
    age = public_send("age#{person_num}")
    economic_status = public_send("ecstat#{person_num}")
    return unless age && economic_status

    tenant_is_retired?(economic_status) && age < 66
  end

  def not_retired_over_soft_max_age?(person_num)
    age = public_send("age#{person_num}")
    economic_status = public_send("ecstat#{person_num}")
    return unless age && economic_status

    return false if tenant_prefers_not_to_say?(economic_status)

    !tenant_is_retired?(economic_status) && age > 66
  end

  def partner_under_16?(person_num)
    age = public_send("age#{person_num}")
    relationship = public_send("relat#{person_num}")
    return unless age && relationship

    age < 16 && relationship == "P"
  end

  def at_least_one_person_working_situation_is_illness?
    person_count = hhmemb || 8

    (1..person_count).any? { |n| public_send("ecstat#{n}") == 8 }
  end

  def no_one_in_household_with_illness?
    return unless illness

    illness == 2
  end
end
