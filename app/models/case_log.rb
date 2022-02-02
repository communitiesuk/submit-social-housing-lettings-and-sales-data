class CaseLogValidator < ActiveModel::Validator
  # Validations methods need to be called 'validate_' to run on model save
  # or form page submission
  include Validations::HouseholdValidations
  include Validations::PropertyValidations
  include Validations::FinancialValidations
  include Validations::TenancyValidations
  include Validations::DateValidations
  include Validations::LocalAuthorityValidations
  include Validations::SubmissionValidations

  def validate(record)
    validation_methods = public_methods.select { |method| method.starts_with?("validate_") }
    validation_methods.each { |meth| public_send(meth, record) }
  end

private

  def validate_other_field(record, main_field, other_field)
    main_field_label = main_field.humanize(capitalize: false)
    other_field_label = other_field.humanize(capitalize: false)
    if record[main_field] == "Other" && record[other_field].blank?
      record.errors.add other_field.to_sym, "If #{main_field_label} is other then #{other_field_label} must be provided"
    end

    if record[main_field] != "Other" && record[other_field].present?
      record.errors.add other_field.to_sym, "#{other_field_label} must not be provided if #{main_field_label} was not other"
    end
  end
end

class CaseLog < ApplicationRecord
  include Discard::Model
  include Validations::SoftValidations
  include Constants::CaseLog
  include Constants::IncomeRanges
  default_scope -> { kept }

  validates_with CaseLogValidator
  before_validation :process_postcode_changes!, if: :property_postcode_changed?
  before_validation :reset_invalidated_dependent_fields!
  before_validation :reset_location_fields!, unless: :postcode_known?
  before_validation :set_derived_fields!
  before_save :update_status!

  belongs_to :owning_organisation, class_name: "Organisation"
  belongs_to :managing_organisation, class_name: "Organisation"

  scope :for_organisation, ->(org) { where(owning_organisation: org).or(where(managing_organisation: org)) }

  enum status: STATUS
  enum letting_in_sheltered_accomodation: SHELTERED_ACCOMODATION
  enum ethnic: ETHNIC
  enum national: NATIONAL, _suffix: true
  enum ecstat1: ECSTAT, _suffix: true
  enum ecstat2: ECSTAT, _suffix: true
  enum ecstat3: ECSTAT, _suffix: true
  enum ecstat4: ECSTAT, _suffix: true
  enum ecstat5: ECSTAT, _suffix: true
  enum ecstat6: ECSTAT, _suffix: true
  enum ecstat7: ECSTAT, _suffix: true
  enum ecstat8: ECSTAT, _suffix: true
  enum relat2: RELAT, _suffix: true
  enum relat3: RELAT, _suffix: true
  enum relat4: RELAT, _suffix: true
  enum relat5: RELAT, _suffix: true
  enum relat6: RELAT, _suffix: true
  enum relat7: RELAT, _suffix: true
  enum relat8: RELAT, _suffix: true
  enum sex2: GENDER, _suffix: true
  enum sex3: GENDER, _suffix: true
  enum sex4: GENDER, _suffix: true
  enum sex5: GENDER, _suffix: true
  enum sex6: GENDER, _suffix: true
  enum sex7: GENDER, _suffix: true
  enum sex8: GENDER, _suffix: true
  enum prevten: PREVIOUS_TENANCY, _suffix: true
  enum homeless: HOMELESS, _suffix: true
  enum underoccupation_benefitcap: BENEFITCAP, _suffix: true
  enum reservist: RESERVIST, _suffix: true
  enum leftreg: LEFTREG, _suffix: true
  enum illness: ILLNESS, _suffix: true
  enum preg_occ: PREGNANCY, _suffix: true
  enum override_net_income_validation: POLAR, _suffix: true
  enum housingneeds_a: POLAR, _suffix: true
  enum housingneeds_b: POLAR, _suffix: true
  enum housingneeds_c: POLAR, _suffix: true
  enum housingneeds_f: POLAR, _suffix: true
  enum housingneeds_g: POLAR, _suffix: true
  enum housingneeds_h: POLAR, _suffix: true
  enum accessibility_requirements_prefer_not_to_say: POLAR, _suffix: true
  enum illness_type_1: POLAR, _suffix: true
  enum illness_type_2: POLAR, _suffix: true
  enum illness_type_3: POLAR, _suffix: true
  enum illness_type_4: POLAR, _suffix: true
  enum illness_type_5: POLAR, _suffix: true
  enum illness_type_6: POLAR, _suffix: true
  enum illness_type_7: POLAR, _suffix: true
  enum illness_type_8: POLAR, _suffix: true
  enum illness_type_9: POLAR, _suffix: true
  enum illness_type_10: POLAR, _suffix: true
  enum startertenancy: POLAR2, _suffix: true
  enum tenancy: TENANCY, _suffix: true
  enum landlord: LANDLORD, _suffix: true
  enum rsnvac: RSNVAC, _suffix: true
  enum unittype_gn: UNITTYPE_GN, _suffix: true
  enum rp_homeless: POLAR, _suffix: true
  enum rp_insan_unsat: POLAR, _suffix: true
  enum rp_medwel: POLAR, _suffix: true
  enum rp_hardship: POLAR, _suffix: true
  enum rp_dontknow: POLAR, _suffix: true
  enum cbl: POLAR2, _suffix: true
  enum chr: POLAR2, _suffix: true
  enum cap: POLAR2, _suffix: true
  enum wchair: POLAR2, _suffix: true
  enum incfreq: INCFREQ, _suffix: true
  enum benefits: BENEFITS, _suffix: true
  enum period: PERIOD, _suffix: true
  enum layear: LATIME, _suffix: true
  enum lawaitlist: LATIME, _suffix: true
  enum reasonpref: POLAR_WITH_UNKNOWN, _suffix: true
  enum reason: REASON, _suffix: true
  enum la: ENGLISH_LA, _suffix: true
  enum prevloc: UK_LA, _suffix: true
  enum majorrepairs: POLAR, _suffix: true
  enum hb: HOUSING_BENEFIT, _suffix: true
  enum hbrentshortfall: POLAR_WITH_UNKNOWN, _suffix: true
  enum property_relet: POLAR, _suffix: true
  enum armedforces: ARMED_FORCES, _suffix: true
  enum first_time_property_let_as_social_housing: POLAR, _suffix: true
  enum unitletas: UNITLETAS, _suffix: true
  enum builtype: BUILTYPE, _suffix: true
  enum incref: POLAR, _suffix: true
  enum renttype: RENT_TYPE, _suffix: true
  enum needstype: NEEDS_TYPE, _suffix: true
  enum lettype: LET_TYPE, _suffix: true
  enum postcode_known: POLAR, _suffix: true
  enum la_known: POLAR, _suffix: true
  enum net_income_known: NET_INCOME_KNOWN, _suffix: true
  enum household_charge: POLAR, _suffix: true
  enum is_carehome: POLAR, _suffix: true
  enum nocharge: POLAR, _suffix: true
  enum referral: REFERRAL, _suffix: true
  enum declaration: POLAR, _suffix: true

  AUTOGENERATED_FIELDS = %w[id status created_at updated_at discarded_at].freeze
  OPTIONAL_FIELDS = %w[postcode_known la_known first_time_property_let_as_social_housing].freeze

  def form
    FormHandler.instance.get_form(form_name)
  end

  def form_name
    return "2021_2022" unless startdate

    window_end_date = Time.zone.local(startdate.year, 4, 1)
    if startdate < window_end_date
      "#{startdate.year - 1}_#{startdate.year}"
    else
      "#{startdate.year}_#{startdate.year + 1}"
    end
  end

  def self.editable_fields
    attribute_names - AUTOGENERATED_FIELDS
  end

  def completed?
    status == "completed"
  end

  def not_started?
    status == "not_started"
  end

  def in_progress?
    status == "in_progress"
  end

  def postcode_known?
    postcode_known == "Yes"
  end

  def weekly_net_income
    return unless earnings && incfreq

    case incfreq
    when "Weekly"
      earnings
    when "Monthly"
      ((earnings * 12) / 52.0).round(0)
    when "Yearly"
      (earnings / 12.0).round(0)
    end
  end

  def applicable_income_range
    return unless ecstat1

    ALLOWED_INCOME_RANGES[ecstat1.to_sym]
  end

  def first_time_property_let_as_social_housing?
    first_time_property_let_as_social_housing == "Yes"
  end

private

  PIO = Postcodes::IO.new

  def update_status!
    self.status = if all_fields_completed? && errors.empty?
                    "completed"
                  elsif all_fields_nil?
                    "not_started"
                  else
                    "in_progress"
                  end
  end

  def reset_invalidated_dependent_fields!
    form.invalidated_page_questions(self).each do |question|
      public_send("#{question.id}=", nil) if respond_to?(question.id.to_s)
    end
  end

  def dynamically_not_required
    (form.invalidated_questions(self) + form.readonly_questions).map(&:id).uniq
  end

  def set_derived_fields!
    if previous_postcode.present?
      self.ppostc1 = UKPostcode.parse(previous_postcode).outcode
      self.ppostc2 = UKPostcode.parse(previous_postcode).incode
    end
    if mrcdate.present?
      self.mrcday = mrcdate.day
      self.mrcmonth = mrcdate.month
      self.mrcyear = mrcdate.year
    end
    if startdate.present?
      self.day = startdate.day
      self.month = startdate.month
      self.year = startdate.year
    end
    self.hhmemb = other_hhmemb + 1 if other_hhmemb.present?
    self.renttype = RENT_TYPE_MAPPING[rent_type]
    self.lettype = "#{renttype} #{needstype} #{owning_organisation[:provider_type]}" if renttype.present? && needstype.present? && owning_organisation[:provider_type].present?
    self.totchild = get_totchild
    self.totelder = get_totelder
    self.totadult = get_totadult
    self.tcharge = brent.to_f + scharge.to_f + pscharge.to_f + supcharg.to_f
    self.has_benefits = get_has_benefits
    self.nocharge = household_charge == "Yes" ? "No" : "Yes"
  end

  def process_postcode_changes!
    return if property_postcode.blank?

    self.postcode_known = "Yes"
    inferred_la = get_inferred_la(property_postcode)
    self.is_la_inferred = inferred_la.present?
    self.la = inferred_la if inferred_la.present?
    self.postcode = UKPostcode.parse(property_postcode).outcode
    self.postcod2 = UKPostcode.parse(property_postcode).incode
  end

  def reset_location_fields!
    if is_la_inferred == true
      self.la = nil
    end
    self.is_la_inferred = false
    self.property_postcode = nil
    self.postcode = nil
    self.postcod2 = nil
  end

  def get_totelder
    ages = [age1, age2, age3, age4, age5, age6, age7, age8]
    ages.count { |x| !x.nil? && x >= 60 }
  end

  def get_totchild
    relationships = [relat2, relat3, relat4, relat5, relat6, relat7, relat8]
    relationships.count("Child - includes young adult and grown-up")
  end

  def get_totadult
    total = !age1.nil? && age1 >= 16 && age1 < 60 ? 1 : 0
    total + (2..8).count do |i|
      age = public_send("age#{i}")
      relat = public_send("relat#{i}")
      !age.nil? && ((age >= 16 && age < 18 && %w[Partner Other].include?(relat)) || age >= 18 && age < 60)
    end
  end

  def get_inferred_la(postcode)
    postcode_lookup = nil
    Timeout.timeout(5) { postcode_lookup = PIO.lookup(postcode) }
    if postcode_lookup && postcode_lookup.info.present?
      postcode_lookup.admin_district
    end
  end

  def get_has_benefits
    return "Yes" if HAS_BENEFITS_OPTIONS.include?(hb)
  end

  def all_fields_completed?
    mandatory_fields.none? { |field| public_send(field).nil? if respond_to?(field) }
  end

  def all_fields_nil?
    init_fields = %w[owning_organisation_id managing_organisation_id]
    fields = mandatory_fields.difference(init_fields)
    fields.none? { |field| public_send(field).present? if respond_to?(field) }
  end

  def mandatory_fields
    form.questions.map(&:id).difference(OPTIONAL_FIELDS, dynamically_not_required)
  end
end
