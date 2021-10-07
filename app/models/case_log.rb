class CaseLogValidator < ActiveModel::Validator

  def validate_tenant_age(record)
    if !record.tenant_age?
      record.errors.add :base, "Tenant age can't be blank"
    elsif record.tenant_age < 0
      record.errors.add :base, "Age needs to be above 0"
    elsif record.tenant_age > 120
      record.errors.add :base, "Age needs to be below 120"
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
