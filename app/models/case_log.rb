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
    if record.reason_for_leaving_last_settled_home == "Other" && record.other_reason_for_leaving_last_settled_home.blank?
      record.errors.add :other_reason_for_leaving_last_settled_home, "If reason for leaving settled home is other then the other reason must be provided"
    end

    if record.reason_for_leaving_last_settled_home != "Other" && record.other_reason_for_leaving_last_settled_home.present?
      record.errors.add :other_reason_for_leaving_last_settled_home, "The other reason must not be provided if the reason for leaving settled home was not other"
    end
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

  def validate_household_pregnancy(record)
    if (record.pregnancy == "Yes" || record.pregnancy == "Prefer not to say") && !women_of_child_bearing_age_in_household(record)
      record.errors.add :pregnancy, "You must answer no as there are no female tenants aged 16-50 in the property"
    end
  end

  def validate_shared_housing_rooms(record)
    number_of_tenants = people_in_household(record)
    if record.property_unit_type == "Bed-sit" && record.property_number_of_bedrooms != 1
      record.errors.add :property_unit_type, "A bedsit can only have one bedroom"
    end

    if people_in_household(record) > 1
      if record.property_unit_type.include? == "Shared" && (record.property_number_of_bedrooms == 0 && record.property_number_of_bedrooms > 7)
        record.errors.add :property_unit_type, "A shared house must have 1 to 7 bedrooms"
      end
    else
      if record.property_unit_type.include? == "Shared" && (record.property_number_of_bedrooms == 0 && record.property_number_of_bedrooms > 3)
        record.errors.add :property_unit_type, "A shared house with one tenant must have 1 to 3 bedrooms"
      end
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
      # This assumes that all methods in this class other than this one are
      # validations to be run
      validation_methods = public_methods(false) - [__callee__]
      validation_methods.each { |meth| public_send(meth, record) }
    end
  end

private

  def women_of_child_bearing_age_in_household(record)
    (1..8).any? do |n|
      next if record["person_#{n}_gender"].nil? || record["person_#{n}_age"].nil?

      record["person_#{n}_gender"] == "Female" && record["person_#{n}_age"] >= 16 && record["person_#{n}_age"] <= 50
    end
  end

  def people_in_household(record)
    count = 0
    (1..8).any? do |n|
      next if record["person_#{n}_gender"].nil? || record["person_#{n}_age"].nil?
      count += 1
    end
    return count
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

    required.delete_if { |key, _value| dynamically_not_required.include?(key) }
  end
end
