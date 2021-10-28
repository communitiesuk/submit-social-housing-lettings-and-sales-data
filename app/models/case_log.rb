class CaseLogValidator < ActiveModel::Validator
  # Methods to be used on save and continue need to be named 'validate_'
  # followed by field name this is how the metaprogramming of the method
  # name being call in the validate method works.

  def validate_person_1_age(record)
    if record.person_1_age && !/^[1-9][0-9]?$|^120$/.match?(record.person_1_age.to_s)
      record.errors.add :person_1_age, "Tenant age must be between 0 and 120"
    end
  end

  def validate_property_number_of_times_relet(record)
    if record.property_number_of_times_relet && !/^[1-9]$|^0[1-9]$|^1[0-9]$|^20$/.match?(record.property_number_of_times_relet.to_s)
      record.errors.add :property_number_of_times_relet, "Must be between 0 and 20"
    end
  end

  def validate_reasonable_preference(record)
    if record.homelessness == "No" && record.reasonable_preference == "Yes"
      record.errors.add :reasonable_preference, "Can not be Yes if Not Homeless immediately prior to this letting has been selected"
    elsif record.reasonable_preference == "Yes"
      if !record.reasonable_preference_reason_homeless && !record.reasonable_preference_reason_unsatisfactory_housing && !record.reasonable_preference_reason_medical_grounds && !record.reasonable_preference_reason_avoid_hardship && !record.reasonable_preference_reason_do_not_know
        record.errors.add :reasonable_preference_reason, "If reasonable preference is Yes, a reason must be given"
      end
    elsif record.reasonable_preference == "No"
      if record.reasonable_preference_reason_homeless || record.reasonable_preference_reason_unsatisfactory_housing || record.reasonable_preference_reason_medical_grounds || record.reasonable_preference_reason_avoid_hardship || record.reasonable_preference_reason_do_not_know
        record.errors.add :reasonable_preference_reason, "If reasonable preference is No, no reasons should be given"
      end
    end
  end

  def validate_other_reason_for_leaving_last_settled_home(record)
    validate_other_field(record, "reason_for_leaving_last_settled_home", "other_reason_for_leaving_last_settled_home")
  end

  def validate_reason_for_leaving_last_settled_home(record)
    if record.reason_for_leaving_last_settled_home == "Do not know" && record.benefit_cap_spare_room_subsidy != "Do not know"
      record.errors.add :benefit_cap_spare_room_subsidy, "must be do not know if tenant’s main reason for leaving is do not know"
    end
  end

  def validate_armed_forces_injured(record)
    if (record.armed_forces == "Yes - a regular" || record.armed_forces == "Yes - a reserve") && record.armed_forces_injured.blank?
      record.errors.add :armed_forces_injured, "You must answer the armed forces injury question if the tenant has served in the armed forces"
    end

    if (record.armed_forces == "No" || record.armed_forces == "Prefer not to say") && record.armed_forces_injured.present?
      record.errors.add :armed_forces_injured, "You must not answer the armed forces injury question if the tenant has not served in the armed forces or prefer not to say was chosen"
    end
  end

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

  def validate_armed_forces_active_response(record)
    if record.armed_forces == "Yes - a regular" && record.armed_forces_active.blank?
      record.errors.add :armed_forces_active, "You must answer the armed forces active question if the tenant has served as a regular in the armed forces"
    end

    if record.armed_forces != "Yes - a regular" && record.armed_forces_active.present?
      record.errors.add :armed_forces_active, "You must not answer the armed forces active question if the tenant has not served as a regular in the armed forces"
    end
  end

  def validate_household_pregnancy(record)
    if (record.pregnancy == "Yes" || record.pregnancy == "Prefer not to say") && !women_of_child_bearing_age_in_household(record)
      record.errors.add :pregnancy, "You must answer no as there are no female tenants aged 16-50 in the property"
    end
  end

  def validate_fixed_term_tenancy(record)
    is_present = record.fixed_term_tenancy.present?
    is_in_range = record.fixed_term_tenancy.to_i.between?(2, 99)
    is_secure = record.tenancy_type == "Fixed term – Secure"
    is_ast = record.tenancy_type == "Fixed term – Assured Shorthold Tenancy (AST)"
    conditions = [
      { condition: !(is_secure || is_ast) && is_present, error: "You must only answer the fixed term tenancy length question if the tenancy type is fixed term" },
      { condition: is_ast && !is_in_range,  error: "Fixed term – Assured Shorthold Tenancy (AST) should be between 2 and 99 years" },
      { condition: is_secure && (!is_in_range && is_present), error: "Fixed term – Secure should be between 2 and 99 years or not specified" },
    ]

    conditions.each { |condition| condition[:condition] ? (record.errors.add :fixed_term_tenancy, condition[:error]) : nil }
  end

  def validate_net_income(record)
    return unless record.person_1_economic_status && record.weekly_net_income

    if record.weekly_net_income > record.applicable_income_range.hard_max
      record.errors.add :net_income, "Net income cannot be greater than #{record.applicable_income_range.hard_max} given the tenant's working situation"
    end

    if record.weekly_net_income < record.applicable_income_range.hard_min
      record.errors.add :net_income, "Net income cannot be less than #{record.applicable_income_range.hard_min} given the tenant's working situation"
    end

    if record.soft_errors.present? && record.override_net_income_validation.blank?
      record.errors.add :override_net_income_validation, "For net incomes that fall outside the expected range you must confirm they're correct"
    end
  end

  def validate_other_tenancy_type(record)
    validate_other_field(record, "tenancy_type", "other_tenancy_type")
  end

  def validate(record)
    # If we've come from the form UI we only want to validate the specific fields
    # that have just been submitted. If we're submitting a log via API or Bulk Upload
    # we want to validate all data fields.
    question_to_validate = options[:previous_page]
    if question_to_validate
      if respond_to?("validate_#{question_to_validate}")
        public_send("validate_#{question_to_validate}", record)
      end
    else
      # This assumes that all methods in this class other than this one are
      # validations to be run
      validation_methods = public_methods(false) - [__callee__]
      validation_methods.each { |meth| public_send(meth, record) }
    end
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

  def women_of_child_bearing_age_in_household(record)
    (1..8).any? do |n|
      next if record["person_#{n}_gender"].nil? || record["person_#{n}_age"].nil?

      record["person_#{n}_gender"] == "Female" && record["person_#{n}_age"] >= 16 && record["person_#{n}_age"] <= 50
    end
  end
end

class CaseLog < ApplicationRecord
  include Discard::Model
  default_scope -> { kept }
  scope :not_started, -> { where(status: "not_started") }
  scope :in_progress, -> { where(status: "in_progress") }
  scope :not_completed, -> { where.not(status: "completed") }
  scope :completed, -> { where(status: "completed") }

  validate :instance_validations
  before_save :update_status!

  attr_writer :previous_page

  enum status: { "not_started" => 0, "in_progress" => 1, "completed" => 2 }

  AUTOGENERATED_FIELDS = %w[id status created_at updated_at discarded_at].freeze

  def instance_validations
    validates_with CaseLogValidator, ({ previous_page: @previous_page } || {})
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

  def weekly_net_income
    case net_income_frequency
    when "Weekly"
      net_income
    when "Monthly"
      ((net_income * 12) / 52.0).round(0)
    when "Yearly"
      (net_income / 12.0).round(0)
    end
  end

  def applicable_income_range
    return unless person_1_economic_status

    IncomeRange::ALLOWED[person_1_economic_status.to_sym]
  end

  def soft_errors()
    soft_errors = {}
    if weekly_net_income && person_1_economic_status && override_net_income_validation.blank?
      if weekly_net_income < applicable_income_range.soft_min && weekly_net_income > applicable_income_range.hard_min
        soft_errors["weekly_net_income"] = OpenStruct.new(
          message: "Net income is lower than expected based on the main tenant's working situation. Are you sure this is correct?",
          hint_text: "This is based on the tenant's work situation: #{person_1_economic_status}"
        )
      elsif weekly_net_income > applicable_income_range.soft_max && weekly_net_income < applicable_income_range.hard_max
        soft_errors["weekly_net_income"] = OpenStruct.new(
          message: "Net income is higher than expected based on the main tenant's working situation. Are you sure this is correct?",
          hint_text: "This is based on the tenant's work situation: #{person_1_economic_status}"
        )
      end
    end
    soft_errors
  end

private

  def update_status!
    self.status = if all_fields_completed? && errors.empty?
                    "completed"
                  elsif all_fields_nil?
                    "not_started"
                  else
                    "in_progress"
                  end
  end

  def all_fields_completed?
    mandatory_fields.none? { |_key, val| val.nil? }
  end

  def all_fields_nil?
    mandatory_fields.all? { |_key, val| val.nil? }
  end

  def mandatory_fields
    required = attributes.except(*AUTOGENERATED_FIELDS)

    dynamically_not_required = []

    if reason_for_leaving_last_settled_home != "Other"
      dynamically_not_required << "other_reason_for_leaving_last_settled_home"
    end

    if net_income.to_i.zero?
      dynamically_not_required << "net_income_frequency"
    end

    if tenancy_type == "Fixed term – Secure"
      dynamically_not_required << "fixed_term_tenancy"
    end

    if tenancy_type != "Other"
      dynamically_not_required << "other_tenancy_type"
    end

    if soft_errors.empty?
      dynamically_not_required << "override_net_income_validation"
    end

    required.delete_if { |key, _value| dynamically_not_required.include?(key) }
  end
end
