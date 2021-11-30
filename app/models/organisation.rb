class Organisation < ApplicationRecord
  has_many :users
  has_many :owned_case_logs, class_name: "CaseLog", foreign_key: "owning_organisation_id"
  has_many :managed_case_logs, class_name: "CaseLog", foreign_key: "managing_organisation_id"

  def case_logs
    CaseLog.for_organisation(self)
  end

  def completed_case_logs
    case_logs.completed
  end

  def not_completed_case_logs
    case_logs.not_completed
  end
end
