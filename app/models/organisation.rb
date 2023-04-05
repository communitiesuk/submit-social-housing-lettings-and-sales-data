class Organisation < ApplicationRecord
  has_many :users, dependent: :delete_all
  has_many :owned_lettings_logs, class_name: "LettingsLog", foreign_key: "owning_organisation_id", dependent: :delete_all
  has_many :managed_lettings_logs, class_name: "LettingsLog", foreign_key: "managing_organisation_id"
  has_many :owned_sales_logs, class_name: "SalesLog", foreign_key: "owning_organisation_id", dependent: :delete_all
  has_many :data_protection_confirmations
  has_many :organisation_rent_periods
  has_many :owned_schemes, class_name: "Scheme", foreign_key: "owning_organisation_id", dependent: :delete_all
  has_many :parent_organisation_relationships, foreign_key: :child_organisation_id, class_name: "OrganisationRelationship"
  has_many :parent_organisations, through: :parent_organisation_relationships
  has_many :child_organisation_relationships, foreign_key: :parent_organisation_id, class_name: "OrganisationRelationship"
  has_many :child_organisations, through: :child_organisation_relationships

  has_many :stock_owner_relationships, foreign_key: :child_organisation_id, class_name: "OrganisationRelationship"
  has_many :stock_owners, through: :stock_owner_relationships, source: :parent_organisation

  has_many :managing_agent_relationships, foreign_key: :parent_organisation_id, class_name: "OrganisationRelationship"
  has_many :managing_agents, through: :managing_agent_relationships, source: :child_organisation

  def affiliated_stock_owners
    ids = []

    if holds_own_stock? && persisted?
      ids << id
    end

    ids.concat(stock_owners.pluck(:id))

    Organisation.where(id: ids)
  end

  scope :search_by_name, ->(name) { where("name ILIKE ?", "%#{name}%") }
  scope :search_by, ->(param) { search_by_name(param) }

  has_paper_trail

  auto_strip_attributes :name

  PROVIDER_TYPE = {
    LA: 1,
    PRP: 2,
  }.freeze

  enum provider_type: PROVIDER_TYPE

  alias_method :la?, :LA?

  validates :name, presence: { message: I18n.t("validations.organisation.name_missing") }
  validates :provider_type, presence: { message: I18n.t("validations.organisation.provider_type_missing") }

  def self.find_by_id_on_multiple_fields(id)
    return if id.nil?

    if id.start_with?("ORG")
      where(id: id[3..]).first
    else
      where(old_visible_id: id).first
    end
  end

  def can_be_managed_by?(organisation:)
    organisation == self || managing_agents.include?(organisation)
  end

  def lettings_logs
    LettingsLog.filter_by_organisation(self)
  end

  def sales_logs
    SalesLog.filter_by_organisation(self)
  end

  def address_string
    %i[address_line1 address_line2 postcode].map { |field| public_send(field) }.join("\n")
  end

  def rent_periods
    organisation_rent_periods.pluck(:rent_period)
  end

  def rent_period_labels
    labels = rent_periods.map { |period| RentPeriod.rent_period_mappings.dig(period.to_s, "value") }
    labels.compact.presence || %w[All]
  end

  def data_protection_confirmed?
    !!data_protection_confirmations.order(created_at: :desc).first&.confirmed
  end

  def data_protection_agreement_string
    data_protection_confirmed? ? "Accepted" : "Not accepted"
  end

  DISPLAY_PROVIDER_TYPE = { "LA": "Local authority", "PRP": "Private registered provider" }.freeze

  def display_provider_type
    DISPLAY_PROVIDER_TYPE[provider_type.to_sym]
  end

  def display_organisation_attributes
    [
      { name: "Name", value: name, editable: true },
      { name: "Address", value: address_string, editable: true },
      { name: "Telephone_number", value: phone, editable: true },
      { name: "Type of provider", value: display_provider_type, editable: false },
      { name: "Registration number", value: housing_registration_no || "", editable: false },
      { name: "Rent_periods", value: rent_period_labels, editable: false, format: :bullet },
      { name: "Owns housing stock", value: holds_own_stock ? "Yes" : "No", editable: false },
      ({ name: "Other stock owners", value: other_stock_owners, editable: false } unless FeatureToggle.managing_owning_enabled?),
      ({ name: "Managing agents", value: managing_agents_label, editable: false } unless FeatureToggle.managing_owning_enabled?),
      { name: "Data protection agreement", value: data_protection_agreement_string, editable: false },
    ].compact
  end

  def has_managing_agents?
    managing_agents.count.positive?
  end
end
