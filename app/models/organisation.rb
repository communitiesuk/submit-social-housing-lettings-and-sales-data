class Organisation < ApplicationRecord
  has_many :users
  has_many :owned_case_logs, class_name: "CaseLog", foreign_key: "owning_organisation_id"
  has_many :managed_case_logs, class_name: "CaseLog", foreign_key: "managing_organisation_id"

  include Constants::DbEnums
  enum "Org type": ORG_TYPE, _suffix: true

  def case_logs
    CaseLog.for_organisation(self)
  end

  def completed_case_logs
    case_logs.completed
  end

  def not_completed_case_logs
    case_logs.not_completed
  end

  def address_string
    %i[address_line1 address_line2 postcode].map { |field| public_send(field) }.join("\n")
  end

  def display_attributes
    {
      name: name,
      address: address_string,
      telephone_number: phone,
      type: "Org type",
      local_authorities_operated_in: local_authorities,
      holds_own_stock: holds_own_stock,
      other_stock_owners: other_stock_owners,
      managing_agents: managing_agents,
    }
  end
end
