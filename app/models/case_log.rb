class CaseLogValidator < ActiveModel::Validator
  # Methods need to be named 'validate_' followed by field name
  # this is how the metaprogramming of the method name being
  # call in the validate method works.

  def validate_tenant_age(record)
    if record.tenant_age && !/^[1-9][0-9]?$|^120$/.match?(record.tenant_age.to_s)
      record.errors.add :tenant_age, "must be between 0 and 120"
    end
  end

  def validate(record)
    question_to_validate = options[:previous_page]
    if question_to_validate && respond_to?("validate_#{question_to_validate}")
      public_send("validate_#{question_to_validate}", record)
    else
      validation_methods = public_methods(false) - [__callee__]
      validation_methods.each { |meth| public_send(meth, record) }
    end
  end
end

class CaseLog < ApplicationRecord
  validate :instance_validations
  before_save :update_status!

  attr_writer :previous_page

  enum status: { "in progress" => 0, "submitted" => 1 }

  def instance_validations
    validates_with CaseLogValidator, ({ previous_page: @previous_page } || {})
  end

  def update_status!
    self.status = (all_fields_completed? && errors.empty? ? "submitted" : "in progress")
  end

  def all_fields_completed?
    non_mandatory_fields = %w[status created_at updated_at id]
    mandatory_fields = attributes.except(*non_mandatory_fields)
    mandatory_fields.none? { |_key, val| val.nil? }
  end
end
