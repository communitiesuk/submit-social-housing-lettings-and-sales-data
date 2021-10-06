class CaseLogValidator < ActiveModel::Validator
  def validate_tenant_age(record)
    if record.tenant_age < 0
      record.errors.add :base, "Age needs to be above 0"
    elsif record.tenant_age > 120
      record.errors.add :base, "Age needs to be below 120"
    end
  end

  def validate(record)
    if record.tenant_age?
      validate_tenant_age(record)
    end
  end
end

class CaseLog < ApplicationRecord
  enum status: { "in progress" => 0, "submitted" => 1 }
  validates_with CaseLogValidator
end
