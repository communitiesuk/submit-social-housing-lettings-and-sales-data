class CaseLogValidator < ActiveModel::Validator

  # Methods need to be named 'validate_' followed by field name
  # this is how the metaprogramming of the method name being 
  # call in the validate method works.

  def validate_tenant_code(record)
    if record.tenant_code.blank?
      record.errors.add :tenant_code, "Tenant code can't be blank"
    end
  end

  def validate_tenant_age(record)
    if record.tenant_age.blank?
      record.errors.add :tenant_age, "Tenant age can't be blank"
    elsif !(record.tenant_age.to_s =~ /^[1-9][0-9]?$|^100$/)
      record.errors.add :tenant_age, "Tenant age must be between 0 and 100"
    end
  end

  def validate(record)
    question_to_validate = options[:previous_page]
    if respond_to?("validate_#{question_to_validate}")
      public_send("validate_#{question_to_validate}", record)
    end
  end
end

class CaseLog < ApplicationRecord 
  validate :instance_validations
  attr_writer :previous_page
  enum status: { "in progress" => 0, "submitted" => 1 }

  def instance_validations
    validates_with CaseLogValidator, ({ previous_page: @previous_page } || {})
  end
end
