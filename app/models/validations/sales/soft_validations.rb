module Validations::Sales::SoftValidations
  include Validations::Sales::SaleInformationValidations

  ALLOWED_INCOME_RANGES_SALES = {
    2024 => {
      1 => OpenStruct.new(soft_min: 5000),
      2 => OpenStruct.new(soft_min: 1500),
      3 => OpenStruct.new(soft_min: 1000),
      5 => OpenStruct.new(soft_min: 2000),
      0 => OpenStruct.new(soft_min: 2000),
    },
    2025 => {
      1 => OpenStruct.new(soft_min: 13_400, soft_max: 150_000),
      2 => OpenStruct.new(soft_min: 2_600, soft_max: 80_000),
      3 => OpenStruct.new(soft_min: 2_080, soft_max: 30_000),
      4 => OpenStruct.new(soft_min: 520, soft_max: 23_400),
      5 => OpenStruct.new(soft_min: 520, soft_max: 80_000),
      6 => OpenStruct.new(soft_min: 520, soft_max: 50_000),
      7 => OpenStruct.new(soft_min: 520, soft_max: 30_000),
      8 => OpenStruct.new(soft_min: 520, soft_max: 150_000),
      9 => OpenStruct.new(soft_min: 520, soft_max: 150_000),
      0 => OpenStruct.new(soft_min: 520, soft_max: 150_000),
    },
  }.freeze

  def income1_outside_soft_range_for_ecstat?
    income1_under_soft_min? || income1_over_soft_max_for_ecstat?
  end

  def income1_more_or_less_text
    income1_under_soft_min? ? "less" : "more"
  end

  def income2_outside_soft_range_for_ecstat?
    income2_under_soft_min? || income2_over_soft_max_for_ecstat?
  end

  def income2_more_or_less_text
    income2_under_soft_min? ? "less" : "more"
  end

  def income1_over_soft_max_for_discounted_ownership?
    return unless income1 && la && discounted_ownership_sale?

    income_over_discounted_sale_soft_max?(income1)
  end

  def income2_over_soft_max_for_discounted_ownership?
    return unless income2 && la && discounted_ownership_sale?

    income_over_discounted_sale_soft_max?(income2)
  end

  def combined_income_over_soft_max_for_discounted_ownership?
    return unless income1 && income2 && la && discounted_ownership_sale?

    income_over_discounted_sale_soft_max?(income1 + income2)
  end

  def staircase_bought_above_fifty?
    stairbought && stairbought > 50
  end

  def mortgage_over_soft_max?
    return false unless mortgage && inc1mort && (inc2mort || not_joint_purchase?)
    return false if income1_used_for_mortgage? && income1.blank? || income2_used_for_mortgage? && income2.blank?

    income_used_for_mortgage = (income1_used_for_mortgage? ? income1 : 0) + (income2_used_for_mortgage? ? income2 : 0)
    mortgage > income_used_for_mortgage * 5
  end

  def wheelchair_when_not_disabled?
    return unless disabled && wheel

    wheel == 1 && disabled == 2
  end

  def savings_over_soft_max?
    soft_max = form.start_year_2025_or_later? && type == 24 ? 200_000 : 100_000

    savings && savings > soft_max
  end

  def deposit_over_soft_max?
    return unless savings && deposit && mortgage_used?

    deposit > savings * 4 / 3
  end

  def extra_borrowing_expected_but_not_reported?
    return unless saledate && !form.start_year_2024_or_later?
    return unless extrabor && mortgage && deposit && value && discount

    extrabor != 1 && mortgage + deposit > value - value * discount / 100
  end

  def purchase_price_out_of_soft_range?
    return unless value && beds && la && sale_range

    !value.between?(sale_range.soft_min, sale_range.soft_max)
  end

  def staircase_owned_out_of_soft_range?
    return unless type && stairowned

    type == 24 && stairowned.between?(76, 100)
  end

  def shared_ownership_deposit_invalid?
    return unless saledate && collection_start_year <= 2023
    return unless mortgage || mortgageused == 2 || mortgageused == 3
    return unless cashdis || !social_homebuy?
    return unless deposit && value && equity

    over_tolerance?(mortgage_deposit_and_discount_total, value * equity / 100, 1)
  end

  def mortgage_plus_deposit_less_than_discounted_value?
    return unless mortgage && deposit && value && discount

    discounted_value = value * (100 - discount) / 100
    mortgage + deposit < discounted_value
  end

  def hodate_3_years_or_more_saledate?
    return unless hodate && saledate

    saledate - hodate >= 3.years
  end

  def hodate_5_years_or_more_saledate?
    return unless hodate && saledate

    saledate - hodate >= 5.years
  end

  def purchase_price_higher_or_lower_text
    value < sale_range.soft_min ? "lower" : "higher"
  end

  def purchase_price_soft_min_or_soft_max
    value < sale_range.soft_min ? sale_range.soft_min : sale_range.soft_max
  end

  def grant_outside_common_range?
    return unless grant && type && saledate
    return if form.start_year_2024_or_later? && (type == 21 || type == 8)

    !grant.between?(9_000, 16_000)
  end

  def service_charges_over_soft_max?
    return unless type && servicecharge && proptype

    soft_max = old_persons_shared_ownership? ? 550 : 300
    servicecharge > soft_max
  end

  def monthly_charges_over_soft_max?
    return unless type && proptype && ownershipsch

    if discounted_ownership_sale?
      return unless mscharge

      soft_max = old_persons_shared_ownership? ? 550 : 300
      mscharge > soft_max
    elsif shared_ownership_scheme?
      return unless servicecharge

      soft_max = old_persons_shared_ownership? ? 550 : 300
      servicecharge > soft_max
    end
  end

  (2..6).each do |person_num|
    define_method("person_#{person_num}_student_not_child?") do
      relat = send("relat#{person_num}")
      ecstat = send("ecstat#{person_num}")
      age = send("age#{person_num}")
      return unless age && ecstat && relat

      age.between?(16, 19) && ecstat == 7 && relat != "C"
    end
  end

  def discounted_ownership_value_invalid?
    return unless saledate && collection_start_year <= 2023
    return unless value && deposit && ownershipsch
    return unless mortgage || mortgageused == 2 || mortgageused == 3
    return unless discount || grant || type == 29

    mortgage_deposit_and_grant_total != value_with_discount && discounted_ownership_sale?
  end

  def buyer1_livein_wrong_for_ownership_type?
    return unless ownershipsch && buy1livein

    (discounted_ownership_sale? || shared_ownership_scheme?) && buy1livein == 2
  end

  def buyer2_livein_wrong_for_ownership_type?
    return unless ownershipsch && buy2livein
    return unless joint_purchase?

    (discounted_ownership_sale? || shared_ownership_scheme?) && buy2livein == 2
  end

  def percentage_discount_invalid?
    return unless discount && proptype

    case proptype
    when 1, 2
      discount > 50
    when 3, 4, 9
      discount > 35
    end
  end

private

  def sale_range
    LaSaleRange.find_by(
      start_year: collection_start_year,
      la:,
      bedrooms: beds_for_la_sale_range,
    )
  end

  def income1_under_soft_min?
    income_under_soft_min?(income1, ecstat1)
  end

  def income2_under_soft_min?
    income_under_soft_min?(income2, ecstat2)
  end

  def income_under_soft_min?(income, ecstat)
    return unless income && ecstat

    income_ranges = form.start_year_2025_or_later? ? ALLOWED_INCOME_RANGES_SALES[2025] : ALLOWED_INCOME_RANGES_SALES[2024]
    return false unless income_ranges[ecstat]

    income < income_ranges[ecstat][:soft_min]
  end

  def income1_over_soft_max_for_ecstat?
    income_over_soft_max?(income1, ecstat1)
  end

  def income2_over_soft_max_for_ecstat?
    income_over_soft_max?(income2, ecstat2)
  end

  def income_over_soft_max?(income, ecstat)
    return unless income && ecstat && form.start_year_2025_or_later?

    return false unless ALLOWED_INCOME_RANGES_SALES[2025][ecstat]

    income > ALLOWED_INCOME_RANGES_SALES[2025][ecstat][:soft_max]
  end

  def income_over_discounted_sale_soft_max?(income)
    (london_property? && income > 90_000) || (property_not_in_london? && income > 80_000)
  end
end
