class SalesLogValidator < ActiveModel::Validator
  include Validations::Sales::SetupValidations
  include Validations::Sales::HouseholdValidations
  include Validations::Sales::PropertyValidations
  include Validations::SharedValidations
  include Validations::Sales::FinancialValidations
  include Validations::Sales::SaleInformationValidations
  include Validations::SharedValidations
  include Validations::LocalAuthorityValidations

  def validate(record)
    validation_methods = public_methods.select { |method| method.starts_with?("validate_") }
    validation_methods.each { |meth| public_send(meth, record) }
  end
end

class SalesLog < Log
  include DerivedVariables::SalesLogVariables
  include Validations::Sales::SoftValidations
  include Validations::SoftValidations
  include MoneyFormattingHelper

  self.inheritance_column = :_type_disabled

  has_paper_trail

  validates_with SalesLogValidator
  before_validation :recalculate_start_year!, if: :saledate_changed?
  before_validation :reset_invalidated_dependent_fields!
  before_validation :process_postcode_changes!, if: :postcode_full_changed?
  before_validation :process_previous_postcode_changes!, if: :ppostcode_full_changed?
  before_validation :reset_location_fields!, unless: :postcode_known?
  before_validation :reset_previous_location_fields!, unless: :previous_postcode_known?
  before_validation :set_derived_fields!
  after_validation :process_uprn_change!, if: :should_process_uprn_change?

  scope :filter_by_year, ->(year) { where(saledate: Time.zone.local(year.to_i, 4, 1)...Time.zone.local(year.to_i + 1, 4, 1)) }
  scope :filter_by_purchaser_code, ->(purchid) { where("purchid ILIKE ?", "%#{purchid}%") }
  scope :search_by, lambda { |param|
    filter_by_purchaser_code(param)
      .or(filter_by_postcode(param))
      .or(filter_by_id(param))
  }
  scope :filter_by_organisation, ->(org, _user = nil) { where(owning_organisation: org) }

  OPTIONAL_FIELDS = %w[saledate_check purchid monthly_charges_value_check old_persons_shared_ownership_value_check othtype discounted_sale_value_check].freeze
  RETIREMENT_AGES = { "M" => 65, "F" => 60, "X" => 65 }.freeze

  def lettings?
    false
  end

  def sales?
    true
  end

  def startdate
    saledate
  end

  def self.editable_fields
    attribute_names
  end

  def form_name
    return unless saledate

    FormHandler.instance.form_name_from_start_year(collection_start_year, "sales")
  end

  def form
    FormHandler.instance.get_form(form_name) || FormHandler.instance.current_sales_form
  end

  def optional_fields
    OPTIONAL_FIELDS + dynamically_not_required
  end

  def dynamically_not_required
    not_required = []
    not_required << "proplen" if proplen_optional?
    not_required << "mortlen" if mortlen_optional?
    not_required << "frombeds" if frombeds_optional?

    not_required |= %w[address_line2 county postcode_full] if saledate && saledate.year >= 2023

    not_required
  end

  def proplen_optional?
    return false unless collection_start_year

    collection_start_year < 2023
  end

  def mortlen_optional?
    return false unless collection_start_year

    collection_start_year < 2023
  end

  def frombeds_optional?
    return false unless collection_start_year

    collection_start_year < 2023
  end

  def not_started?
    status == "not_started"
  end

  def completed?
    status == "completed"
  end

  def setup_completed?
    form.setup_sections.all? { |sections| sections.subsections.all? { |subsection| subsection.status(self) == :completed } }
  end

  def unresolved
    false
  end

  LONDON_BOROUGHS = %w[
    E09000001
    E09000033
    E09000020
    E09000013
    E09000032
    E09000022
    E09000028
    E09000030
    E09000012
    E09000019
    E09000007
    E09000005
    E09000009
    E09000018
    E09000027
    E09000021
    E09000024
    E09000029
    E09000008
    E09000006
    E09000023
    E09000011
    E09000004
    E09000016
    E09000002
    E09000026
    E09000025
    E09000031
    E09000014
    E09000010
    E09000003
    E09000015
    E09000017
  ].freeze

  def london_property?
    la && LONDON_BOROUGHS.include?(la)
  end

  def property_not_in_london?
    !london_property?
  end

  def income1_used_for_mortgage?
    inc1mort == 1
  end

  def buyer_two_will_live_in_property?
    buy2livein == 1
  end

  def buyer_two_not_already_living_in_property?
    buy2living == 2
  end

  def income2_used_for_mortgage?
    inc2mort == 1
  end

  def right_to_buy?
    [9, 14, 27].include?(type)
  end

  def rent_to_buy_full_ownership?
    type == 29
  end

  def outright_sale_or_discounted_with_full_ownership?
    ownershipsch == 3 || (ownershipsch == 2 && rent_to_buy_full_ownership?)
  end

  def is_type_discount?
    type == 18
  end

  def ppostcode_full=(postcode)
    if postcode
      super UKPostcode.parse(postcode).to_s
    else
      super nil
    end
  end

  def previous_postcode_known?
    ppcodenk&.zero?
  end

  def postcode_known?
    pcodenk&.zero?
  end

  def postcode_full=(postcode)
    if postcode
      super UKPostcode.parse(postcode).to_s
    else
      super nil
    end
  end

  def expected_shared_ownership_deposit_value
    return unless value && equity

    format_as_currency(value * equity / 100)
  end

  def process_postcode(postcode, postcode_known_key, la_inferred_key, la_key)
    return if postcode.blank?

    self[postcode_known_key] = 0
    inferred_la = get_inferred_la(postcode)
    self[la_inferred_key] = inferred_la.present?
    self[la_key] = inferred_la if inferred_la.present?
  end

  def outright_sale?
    ownershipsch == 3
  end

  def discounted_ownership_sale?
    ownershipsch == 2
  end

  def mortgage_used?
    mortgageused == 1
  end

  def mortgage_not_used?
    mortgageused == 2
  end

  def process_postcode_changes!
    self.postcode_full = upcase_and_remove_whitespace(postcode_full)
    process_postcode(postcode_full, "pcodenk", "is_la_inferred", "la")
  end

  def reset_created_by!
    return unless updated_by&.support?
    return if owning_organisation.blank? || created_by.blank?
    return if created_by&.organisation == owning_organisation

    update!(created_by: nil)
  end

  def retirement_age_for_person(person_num)
    gender = public_send("sex#{person_num}".to_sym)
    return unless gender

    RETIREMENT_AGES[gender]
  end

  def joint_purchase?
    jointpur == 1
  end

  def not_joint_purchase?
    jointpur == 2
  end

  def buyer_not_interviewed?
    noint == 1
  end

  def old_persons_shared_ownership?
    type == 24
  end

  def is_bedsit?
    proptype == 2
  end

  def shared_ownership_scheme?
    ownershipsch == 1
  end

  def company_buyer?
    companybuy == 1
  end

  def monthly_leasehold_charges_unknown?
    mscharge_known&.zero?
  end

  def buyers_age_for_old_persons_shared_ownership_invalid?
    return unless old_persons_shared_ownership?

    (joint_purchase? && ages_unknown_or_under_64?([1, 2])) || (not_joint_purchase? && ages_unknown_or_under_64?([1]))
  end

  def ages_unknown_or_under_64?(person_indexes)
    person_indexes.all? { |person_num| self["age#{person_num}"].present? && self["age#{person_num}"] < 64 || self["age#{person_num}_known"] == 1 }
  end

  def purchase_price_soft_min
    LaSaleRange.find_by(start_year: collection_start_year, la:, bedrooms: beds).soft_min
  end

  def purchase_price_soft_max
    LaSaleRange.find_by(start_year: collection_start_year, la:, bedrooms: beds).soft_max
  end

  def income_soft_min_for_ecstat(ecstat_field)
    economic_status_code = public_send(ecstat_field)

    return unless ALLOWED_INCOME_RANGES_SALES

    soft_min = ALLOWED_INCOME_RANGES_SALES[economic_status_code]&.soft_min
    format_as_currency(soft_min)
  end

  def field_formatted_as_currency(field_name)
    field_value = public_send(field_name)
    format_as_currency(field_value)
  end

  def should_process_uprn_change?
    uprn_changed? && saledate && saledate.year >= 2023
  end

  def value_with_discount
    return if value.blank?

    discount_amount = discount ? value * discount / 100 : 0
    value - discount_amount
  end

  def mortgage_deposit_and_grant_total
    return if deposit.blank?

    grant_amount = grant || 0
    mortgage_amount = mortgage || 0
    mortgage_amount + deposit + grant_amount
  end
end
