class CaseLogValidator < ActiveModel::Validator

  def validate_tenant_age(record)
    if !record.tenant_age?
      record.errors.add :base, "Tenant age can't be blank"
    elsif !(record.tenant_age.to_s =~ /^[1-9][0-9]?$|^100$/)
      record.errors.add :base, "Tenant age must be between 0 and 100"
    end
  end

  def validate(record)
    question_to_validate = options[:previous_page]

    if question_to_validate == "tenant_code"
      if !record.tenant_code?
        record.errors.add :base, "Tenant code can't be blank"
      end
    elsif question_to_validate == "tenant_age"
        validate_tenant_age(record)
    end
  end
end

class CaseLog < ApplicationRecord 
  validate :instance_validations
  attr_accessor :custom_validator_options
  enum status: { "in progress" => 0, "submitted" => 1 }
  def instance_validations
    validates_with CaseLogValidator, (custom_validator_options || {})
  end
end
