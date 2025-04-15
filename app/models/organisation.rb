class Organisation < ApplicationRecord
  has_many :users, dependent: :delete_all
  has_many :data_protection_officers, -> { where(is_dpo: true) }, class_name: "User"
  has_one :data_protection_confirmation
  has_many :organisation_rent_periods, dependent: :destroy
  has_many :owned_schemes, class_name: "Scheme", foreign_key: "owning_organisation_id", dependent: :delete_all
  has_many :parent_organisation_relationships, foreign_key: :child_organisation_id, class_name: "OrganisationRelationship"
  has_many :parent_organisations, through: :parent_organisation_relationships
  has_many :child_organisation_relationships, foreign_key: :parent_organisation_id, class_name: "OrganisationRelationship"
  has_many :child_organisations, through: :child_organisation_relationships
  has_many :organisation_name_changes, dependent: :destroy

  has_many :stock_owner_relationships, foreign_key: :child_organisation_id, class_name: "OrganisationRelationship"
  has_many :stock_owners, through: :stock_owner_relationships, source: :parent_organisation

  has_many :managing_agent_relationships, foreign_key: :parent_organisation_id, class_name: "OrganisationRelationship"
  has_many :managing_agents, through: :managing_agent_relationships, source: :child_organisation

  belongs_to :absorbing_organisation, class_name: "Organisation", optional: true
  has_many :absorbed_organisations, class_name: "Organisation", foreign_key: "absorbing_organisation_id"
  scope :visible, -> { where(discarded_at: nil) }
  scope :affiliated_organisations, ->(organisation) { where(id: (organisation.child_organisations + [organisation] + organisation.parent_organisations + organisation.absorbed_organisations).map(&:id)) }

  def affiliated_stock_owners
    ids = []

    if holds_own_stock? && persisted?
      ids << id
    end

    absorbed_organisations.each do |organisation|
      ids.concat(organisation.stock_owners.pluck(:id))
      ids << organisation.id if organisation.holds_own_stock?
    end

    ids.concat(stock_owners.pluck(:id))

    Organisation.where(id: ids)
  end

  scope :search_by_name, ->(name) { where("name ILIKE ?", "%#{name}%") }
  scope :search_by, ->(param) { search_by_name(param) }
  scope :filter_by_active, -> { where(active: true) }
  scope :filter_by_inactive, -> { where(active: false) }
  scope :merged_during_open_collection_period, -> { where("merge_date >= ?", FormHandler.instance.start_date_of_earliest_open_for_editing_collection_period) }
  scope :merged_during_displayed_collection_period, -> { where("merge_date >= ?", FormHandler.instance.start_date_of_earliest_lettings_form) }

  has_paper_trail

  auto_strip_attributes :name, squish: true

  PROVIDER_TYPE = {
    LA: 1,
    PRP: 2,
  }.freeze

  enum :provider_type, PROVIDER_TYPE

  alias_method :la?, :LA?

  validates :name, presence: { message: I18n.t("validations.organisation.name_missing") }
  validates :name, uniqueness: { case_sensitive: false, message: I18n.t("validations.organisation.name_not_unique") }
  validates :provider_type, presence: { message: I18n.t("validations.organisation.provider_type_missing") }

  def self.find_by_id_on_multiple_fields(id)
    return if id.nil?

    if id.start_with?("ORG")
      where(id: id[3..]).first
    else
      where(old_visible_id: id).first
    end
  end

  def name(date: Time.zone.now)
    name_change = organisation_name_changes.visible.find { |change| change.includes_date?(date) }
    name_change&.name || read_attribute(:name)
  end

  def name_changes_with_dates
    changes = fetch_name_changes_with_dates

    if changes.any?
      changes.unshift({
                        name: self[:name],
                        start_date: created_at,
                        end_date: changes.first[:start_date]&.yesterday,
                        status: Time.zone.now.to_date < changes.first[:start_date].to_date ? "scheduled" : "inactive",
                      })
    else
      changes << { name: self[:name], start_date: created_at, end_date: nil, status: "active" }
    end

    changes.each do |change|
      change[:status] ||= if change[:start_date].to_date > Time.zone.now.to_date
                            "scheduled"
                          elsif change[:end_date].nil? || change[:end_date].to_date >= Time.zone.now.to_date
                            "active"
                          else
                            "inactive"
                          end
    end

    changes
  end

  def fetch_name_changes_with_dates
    organisation_name_changes.visible.order(:startdate).map.with_index do |change, index|
      next_change = organisation_name_changes.visible.order(:startdate)[index + 1]
      {
        name: change.name,
        start_date: change.startdate,
        end_date: next_change&.startdate&.yesterday,
      }
    end
  end

  def can_be_managed_by?(organisation:)
    organisation == self || managing_agents.include?(organisation)
  end

  def lettings_logs
    LettingsLog.filter_by_organisation(absorbed_organisations + [self])
  end

  def sales_logs
    SalesLog.filter_by_organisation(absorbed_organisations + [self])
  end

  def owned_lettings_logs
    LettingsLog.filter_by_owning_organisation(absorbed_organisations + [self])
  end

  def owned_sales_logs
    SalesLog.filter_by_owning_organisation(absorbed_organisations + [self])
  end

  def managed_lettings_logs
    LettingsLog.filter_by_managing_organisation(absorbed_organisations + [self])
  end

  def managed_sales_logs
    SalesLog.filter_by_managing_organisation(absorbed_organisations + [self])
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
    rent_period_ids = rent_periods
    mappings = RentPeriod.rent_period_mappings
    return %w[All] if (mappings.keys.map(&:to_i) - rent_period_ids).empty?

    rent_period_ids.map { |id| mappings.dig(id.to_s, "value") }.compact.uniq.sort_by do |label|
      mappings.keys.index { |key| mappings[key]["value"] == label }
    end
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
    return :deleted if discarded_at.present?
    return :merged if merge_date.present? && merge_date < date
    return :deactivated unless active

    :active
  end

  def editable_duplicate_lettings_logs_sets
    lettings_logs.after_date(FormHandler.instance.lettings_earliest_open_for_editing_collection_start_date).duplicate_sets.map { |array_str| array_str ? array_str.map(&:to_i) : [] }
  end

  def editable_duplicate_sales_logs_sets
    sales_logs.after_date(FormHandler.instance.sales_earliest_open_for_editing_collection_start_date).duplicate_sets.map { |array_str| array_str ? array_str.map(&:to_i) : [] }
  end

  def organisations_absorbed_during_displayed_collection_period_grouped_by_merge_date
    return unless absorbed_organisations.merged_during_displayed_collection_period.exists?

    absorbed_organisations.merged_during_displayed_collection_period.group_by(&:merge_date)
  end

  def has_recent_absorbed_organisations?
    absorbed_organisations.merged_during_open_collection_period.exists?
  end

  def has_organisations_absorbed_during_displayed_collection_period?
    absorbed_organisations.merged_during_displayed_collection_period.exists?
  end

  def organisation_or_stock_owner_signed_dsa_and_holds_own_stock?
    return true if data_protection_confirmed? && holds_own_stock?
    return true if stock_owners.any? { |stock_owner| stock_owner.data_protection_confirmed? && stock_owner.holds_own_stock? }
    return true if absorbed_organisations.any? { |stock_owner| stock_owner.data_protection_confirmed? && stock_owner.holds_own_stock? }

    false
  end

  def discard!
    owned_schemes.each(&:discard!)
    users.each(&:discard!)
    update!(discarded_at: Time.zone.now)
  end

  def label(date:)
    date ||= Time.zone.now
    status == :deleted ? "#{name(date:)} (deleted)" : name(date:)
  end

  def has_visible_users?
    users.visible.count.positive?
  end

  def has_visible_schemes?
    owned_schemes.visible.count.positive?
  end
end
