class CaseLogValidator < ActiveModel::Validator
  # Validations methods need to be called 'validate_' to run on model save
  include HouseholdValidations
  include PropertyValidations
  include FinancialValidations
  include TenancyValidations

  def validate_other_household_members(record)
    index = 0
    number_of_other_members = record.household_number_of_other_members
    partner = false

    while index < number_of_other_members
      
      member_number = index+2
      relationship = record["person_#{member_number}_relationship"]
      age = record["person_#{member_number}_age"]
      gender = record["person_#{member_number}_gender"]
      economic_status = record["person_#{member_number}_economic_status"]

      binding.pry
      if relationship || age || gender || economic_status
        if relationship.nil? || age.nil? || gender.nil? || economic_status.nil?
          record.errors.add "person_#{member_number}_age", "If any of the person is filled out it must all be filled"
        end
      end

      if age<1 || age>120
        record.errors.add "person_#{member_number}_age", "Tenant #{member_number} age must be between 1 and 120 (i.e. infants must be entered as 1)"
      end

      if age>70 && economic_status != "Retired"
        record.errors.add "person_#{member_number}_economic_status", "Tenant #{member_number} must be retired if over 70"
      end

      if gender=="Male" && economic_status == "Retired" && age<65
        record.errors.add "person_#{member_number}_age", "Male tenant who is retired must be 65 or over"
      end

      if gender=="Female" && economic_status == "Retired" && age<60
        record.errors.add "person_#{member_number}_age", "Female tenant who is retired must be 60 or over"
      end

      if age>70 && economic_status != "Retired"
        record.errors.add "person_#{member_number}_economic_status", "Tenant #{member_number} must be retired if over 70"
      end

      if age<16 
        if relationship != "Child - includes young adult and grown-up"
          record.errors.add "person_#{member_number}_relationship", "Tenant #{member_number}'s relationship to tenant 1 must be Child if their age is under 16"
        end
        if economic_status != "Child under 16"
          record.errors.add "person_#{member_number}_economic_status", "Tenant #{member_number} economic status must be Child under 16 if their age is under 16"
        end
      end

      if relationship == "Partner"
        if partner
          record.errors.add "person_#{member_number}_relationship", "Tenant can not have multiple partners"
        elsif age<16 || economic_status == "Child under 16"
          record.errors.add "person_#{member_number}_relationship", "Tenant can not be tenant 1's partner if they are under 16"
        else
          partner = true
        end
      end

      if relationship == "Child - includes young adult and grown-up"
        if economic_status!="Unable to work because of long term sick or disability" || economic_status!="Other" || economic_status!="Prefer not to say"
          record.errors.add "person_#{member_number}_economic_status", "This is not a valid economic status for a child"
        end

        if age>=16 && age<=19 
          if economic_status != "Full-time student" || economic_status != "Prefer not to say"
            record.errors.add "person_#{member_number}_economic_status", "If relationship is child and age is between 16 and 19 - tenant #{member_number} must be a full time student or prefer not to say."
          end
        end
      end
      
      index = index+1
    end
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
      validation_methods = public_methods.select { |method| method.starts_with?("validate_") }
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

    unless tenancy_type == "Other"
      dynamically_not_required << "other_tenancy_type"
    end

    unless net_income_known == "Yes"
      dynamically_not_required << "net_income"
      dynamically_not_required << "net_income_frequency"
    end

    required.delete_if { |key, _value| dynamically_not_required.include?(key) }
  end
end
