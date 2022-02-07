class Organisation < ApplicationRecord
  has_many :users
  has_many :owned_case_logs, class_name: "CaseLog", foreign_key: "owning_organisation_id"
  has_many :managed_case_logs, class_name: "CaseLog", foreign_key: "managing_organisation_id"

  include Constants::Organisation
  enum provider_type: PROVIDER_TYPE

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
    [
      { name: "name", value: name, editable: true },
      { name: "address", value: address_string, editable: true },
      { name: "telephone_number", value: phone, editable: true },
      { name: "type", value: "Org type", editable: false },
      { name: "local_authorities_operated_in", value: local_authorities, editable: false },
      { name: "holds_own_stock", value: holds_own_stock, editable: false },
      { name: "other_stock_owners", value: other_stock_owners, editable: false },
      { name: "managing_agents", value: managing_agents, editable: false },
    ]
  end
end
