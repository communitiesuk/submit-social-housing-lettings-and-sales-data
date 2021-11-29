class Organisation < ApplicationRecord
  has_many :users
  has_many :owned_case_logs, class_name: "CaseLog", foreign_key: "owning_organisation_id"
  has_many :managed_case_logs, class_name: "CaseLog", foreign_key: "managing_organisation_id"
end
