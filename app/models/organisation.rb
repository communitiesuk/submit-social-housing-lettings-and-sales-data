class Organisation < ApplicationRecord
  has_many :users, dependent: :delete_all
  has_many :data_protection_officers, -> { where(is_dpo: true) }, class_name: "User"
  has_one :data_protection_confirmation
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

  belongs_to :absorbing_organisation, class_name: "Organisation", optional: true
  has_many :absorbed_organisations, class_name: "Organisation", foreign_key: "absorbing_organisation_id"

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
  scope :merged_during_open_collection_period, -> { where("merge_date >= ?", FormHandler.instance.start_date_of_earliest_open_for_editing_collection_period) }

  has_paper_trail

  auto_strip_attributes :name, squish: true

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
    LettingsLog.filter_by_organisation(absorbed_organisations + [self])
  end

  def sales_logs
    SalesLog.filter_by_owning_organisation(absorbed_organisations + [self])
  end

  def owned_lettings_logs
    LettingsLog.filter_by_owning_organisation(absorbed_organisations + [self])
  end

  def owned_sales_logs
    sales_logs
  end

  def managed_lettings_logs
    LettingsLog.filter_by_managing_organisation(absorbed_organisations + [self])
  end

  def address_string
    %i[address_line1 address_line2 postcode].map { |field| public_send(field) }.join("\n")
  end

  def address_row
    %i[address_line1 address_line2 postcode].map { |field| public_send(field) }.join(", ")
  end

  def rent_periods
    organisation_rent_periods.pluck(:rent_period)
  end

  def rent_period_labels
    labels = rent_periods.map { |period| RentPeriod.rent_period_mappings.dig(period.to_s, "value") }
    labels.compact.presence || %w[All]
  end

  def data_protection_confirmed?
    !!data_protection_confirmation&.confirmed?
  end

  def data_protection_agreement_string
    data_protection_confirmed? ? "Accepted" : "Not accepted"
  end

  DISPLAY_PROVIDER_TYPE = { "LA": "Local authority", "PRP": "Private registered provider" }.freeze

  def display_provider_type
    DISPLAY_PROVIDER_TYPE[provider_type.to_sym]
  end

  def has_managing_agents?
    managing_agents.count.positive?
  end

  def has_stock_owners?
    stock_owners.count.positive?
  end

  def status
    @status ||= status_at(Time.zone.now)
  end

  def status_at(date)
    return :merged if merge_date.present? && merge_date < date

    :active
  end

  def editable_duplicate_lettings_logs_sets
    lettings_logs.duplicate_sets.map { |array_str| array_str ? array_str.map(&:to_i) : [] }
                 .select { |set| LettingsLog.find(set.first).collection_period_open_for_editing? }
  end

  def editable_duplicate_sales_logs_sets
    sales_logs.duplicate_sets.map { |array_str| array_str ? array_str.map(&:to_i) : [] }
              .select { |set| SalesLog.find(set.first).collection_period_open_for_editing? }
  end

  def recently_absorbed_organisations_grouped_by_merge_date
    return unless absorbed_organisations.present? && absorbed_organisations.merged_during_open_collection_period.present?

    absorbed_organisations.merged_during_open_collection_period.group_by(&:merge_date)
  end
end
