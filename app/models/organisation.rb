class Organisation < ApplicationRecord
  has_many :users
  has_many :owned_case_logs, class_name: "CaseLog", foreign_key: "owning_organisation_id"
  has_many :managed_case_logs, class_name: "CaseLog", foreign_key: "managing_organisation_id"
  has_many :data_protection_confirmations
  has_many :organisation_las
  has_many :organisation_rent_periods

  has_paper_trail

  PROVIDER_TYPE = {
    LA: 1,
    PRP: 2,
  }.freeze

  enum provider_type: PROVIDER_TYPE

  validates :provider_type, presence: true

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

  def data_protection_confirmed?
    !!data_protection_confirmations.order(created_at: :desc).first&.confirmed
  end

  def local_authorities
    organisation_las.pluck(:ons_code)
  end

  def local_authority_names
    local_authorities.map { |ons_code| LocalAuthority.ons_code_mappings[ons_code] }
  end

  def rent_periods
    organisation_rent_periods.pluck(:rent_period)
  end

  def rent_period_labels
    rent_periods.map { |period| RentPeriod.rent_period_mappings[period.to_s]["value"] }
  end

  def display_attributes
    [
      { name: "name", value: name, editable: true },
      { name: "address", value: address_string, editable: true },
      { name: "telephone_number", value: phone, editable: true },
      { name: "type", value: "Org type", editable: false },
      { name: "local_authorities_operated_in", value: local_authority_names, editable: false, format: :bullet },
      { name: "rent_periods", value: rent_period_labels, editable: false, format: :bullet },
      { name: "holds_own_stock", value: holds_own_stock.to_s.humanize, editable: false },
      { name: "other_stock_owners", value: other_stock_owners, editable: false },
      { name: "managing_agents", value: managing_agents, editable: false },
      { name: "has_signed_data_protection_agreement?", value: data_protection_confirmed?.to_s.humanize, editable: false },
    ]
  end
end
