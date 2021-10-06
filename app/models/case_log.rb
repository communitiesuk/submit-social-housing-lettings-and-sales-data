class CaseLog < ApplicationRecord
  enum status: { "in progress" => 0, "submitted" => 1 }

  # validates :tenant_age, presence: true
end
