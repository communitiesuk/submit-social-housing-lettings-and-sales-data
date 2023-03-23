class Scheme < ApplicationRecord
  belongs_to :owning_organisation, class_name: "Organisation"
  has_many :locations, dependent: :delete_all
  has_many :lettings_logs, class_name: "LettingsLog", dependent: :delete_all
  has_many :scheme_deactivation_periods, class_name: "SchemeDeactivationPeriod"

  has_paper_trail

  scope :filter_by_id, ->(id) { where(id: (id.start_with?("S") ? id[1..] : id)) }
  scope :search_by_service_name, ->(name) { where("service_name ILIKE ?", "%#{name}%") }
  scope :search_by_postcode, ->(postcode) { left_joins(:locations).where("REPLACE(locations.postcode, ' ', '') ILIKE ?", "%#{postcode.delete(' ')}%") }
  scope :search_by_location_name, ->(name) { left_joins(:locations).where("locations.name ILIKE ?", "%#{name}%") }
  scope :search_by, lambda { |param|
                      search_by_postcode(param)
                        .or(search_by_service_name(param))
                        .or(search_by_location_name(param))
                        .or(filter_by_id(param)).distinct
                    }

  scope :order_by_completion, -> { order("confirmed ASC NULLS FIRST") }
  scope :order_by_service_name, -> { order(service_name: :asc) }

  validate :validate_confirmed
  validate :validate_owning_organisation

  auto_strip_attributes :service_name

  SENSITIVE = {
    No: 0,
    Yes: 1,
  }.freeze

  enum sensitive: SENSITIVE, _suffix: true

  REGISTERED_UNDER_CARE_ACT = {
    "Yes – registered care home providing nursing care": 4,
    "Yes – registered care home providing personal care": 3,
    "Yes – part registered as a care home": 2,
    "No": 1,
  }.freeze

  enum registered_under_care_act: REGISTERED_UNDER_CARE_ACT

  SCHEME_TYPE = {
    "Direct Access Hostel": 5,
    "Foyer": 4,
    "Housing for older people": 7,
    "Other Supported Housing": 6,
    "Missing": 0,
  }.freeze

  enum scheme_type: SCHEME_TYPE, _suffix: true

  SUPPORT_TYPE = {
    "Missing": 0,
    "Low level": 2,
    "Medium level": 3,
    "High level": 4,
    "Nursing care in a care home": 5,
  }.freeze

  enum support_type: SUPPORT_TYPE, _suffix: true

  PRIMARY_CLIENT_GROUP = {
    "Homeless families with support needs": "O",
    "Offenders and people at risk of offending": "H",
    "Older people with support needs": "M",
    "People at risk of domestic violence": "L",
    "People with a physical or sensory disability": "A",
    "People with alcohol problems": "G",
    "People with drug problems": "F",
    "People with HIV or AIDS": "B",
    "People with learning disabilities": "D",
    "People with mental health problems": "E",
    "Refugees (permanent)": "I",
    "Rough sleepers": "S",
    "Single homeless people with support needs": "N",
    "Teenage parents": "R",
    "Young people at risk": "Q",
    "Young people leaving care": "P",
    "Missing": "X",
  }.freeze

  enum primary_client_group: PRIMARY_CLIENT_GROUP, _suffix: true
  enum secondary_client_group: PRIMARY_CLIENT_GROUP, _suffix: true

  INTENDED_STAY = {
    "Very short stay": "V",
    "Short stay": "S",
    "Medium stay": "M",
    "Permanent": "P",
    "Missing": "X",
  }.freeze

  HAS_OTHER_CLIENT_GROUP = {
    No: 0,
    Yes: 1,
  }.freeze

  enum intended_stay: INTENDED_STAY, _suffix: true
  enum has_other_client_group: HAS_OTHER_CLIENT_GROUP, _suffix: true

  ARRANGEMENT_TYPE = {
    "The same organisation that owns the housing stock": "D",
    "Another registered stock owner": "R",
    "A registered charity or voluntary organisation": "V",
    "Another organisation": "O",
    "Missing": "X",
  }.freeze

  enum arrangement_type: ARRANGEMENT_TYPE, _suffix: true

  def self.find_by_id_on_mulitple_fields(id)
    return if id.nil?

    if id.start_with?("S")
      where(id: id[1..]).first
    else
      where(old_visible_id: id).first
    end
  end

  def id_to_display
    "S#{id}"
  end

  def check_details_attributes
    [
      { name: "Scheme code", value: id_to_display, id: "id" },
      { name: "Name", value: service_name, id: "service_name" },
      { name: "Confidential information", value: sensitive, id: "sensitive" },
      { name: "Type of scheme", value: scheme_type, id: "scheme_type" },
      { name: "Registered under Care Standards Act 2000", value: registered_under_care_act, id: "registered_under_care_act" },
      { name: "Housing stock owned by", value: owning_organisation.name, id: "owning_organisation_id" },
      { name: "Support services provided by", value: arrangement_type, id: "arrangement_type" },
    ]
  end

  def check_primary_client_attributes
    [
      { name: "Primary client group", value: primary_client_group, id: "primary_client_group" },
    ]
  end

  def check_secondary_client_confirmation_attributes
    [
      { name: "Has another client group", value: has_other_client_group, id: "has_other_client_group" },
    ]
  end

  def check_secondary_client_attributes
    [
      { name: "Secondary client group", value: secondary_client_group, id: "secondary_client_group" },
    ]
  end

  def check_support_attributes
    [
      { name: "Level of support given", value: support_type, id: "support_type" },
      { name: "Intended length of stay", value: intended_stay, id: "intended_stay" },
    ]
  end

  def synonyms
    locations.map(&:postcode).join(",")
  end

  def appended_text
    "#{confirmed_locations_count} completed #{'location'.pluralize(confirmed_locations_count)}, #{unconfirmed_locations_count} incomplete #{'location'.pluralize(unconfirmed_locations_count)}"
  end

  def hint
    [primary_client_group, secondary_client_group].filter(&:present?).join(", ")
  end

  def care_acts_options_with_hints
    hints = { "Yes – part registered as a care home": "A proportion of units are registered as being a care home." }

    Scheme.registered_under_care_acts.keys.map { |key, _| OpenStruct.new(id: key, name: key.to_s.humanize, description: hints[key.to_sym]) }
  end

  def support_level_options_with_hints
    hints = {
      "Low level": "Staff visiting once a week, fortnightly or less.",
      "Medium level": "Staff on site daily or making frequent visits with some out-of-hours cover.",
      "High level": "Intensive level of staffing provided on a 24-hour basis.",
    }
    Scheme.support_types.keys.excluding("Missing").map { |key, _| OpenStruct.new(id: key, name: key.to_s.humanize, description: hints[key.to_sym]) }
  end

  def intended_length_of_stay_options_with_hints
    hints = {
      "Very short stay": "Up to one month.",
      "Short stay": "Up to one year.",
      "Medium stay": "More than one year but with an expectation to move on.",
      "Permanent": "Provides a home for life with no requirement for the tenant to move.",

    }
    Scheme.intended_stays.keys.excluding("Missing").map { |key, _| OpenStruct.new(id: key, name: key.to_s.humanize, description: hints[key.to_sym]) }
  end

  def validate_confirmed
    required_attributes = attribute_names - %w[id created_at updated_at old_id old_visible_id confirmed end_date sensitive secondary_client_group total_units has_other_client_group deactivation_date deactivation_date_type]

    if confirmed == true
      required_attributes.any? do |attribute|
        if self[attribute].blank?
          errors.add attribute.to_sym
          self.confirmed = false
        end
      end
    end
  end

  def validate_owning_organisation
    unless owning_organisation.holds_own_stock?
      errors.add(:owning_organisation_id, :does_not_own_stock, message: I18n.t("validations.scheme.owning_organisation.does_not_own_stock"))
    end
  end

  def available_from
    FormHandler.instance.collection_start_date(created_at)
  end

  def open_deactivation
    scheme_deactivation_periods.deactivations_without_reactivation.first
  end

  def recent_deactivation
    scheme_deactivation_periods.order("created_at").last
  end

  def status
    @status ||= status_at(Time.zone.now)
  end

  def status_at(date)
    return :incomplete unless confirmed && has_completed_locations?
    return :deactivated if open_deactivation&.deactivation_date.present? && date >= open_deactivation.deactivation_date
    return :deactivating_soon if open_deactivation&.deactivation_date.present? && date < open_deactivation.deactivation_date
    return :reactivating_soon if recent_deactivation&.reactivation_date.present? && date < recent_deactivation.reactivation_date

    :active
  end

  def active?
    status == :active
  end

  def reactivating_soon?
    status == :reactivating_soon
  end

  def deactivated?
    status == :deactivated
  end

  def has_completed_locations?
    completed_locations_count.positive?
  end

private

  def completed_locations_count
    locations.count { |location| location.status != :incomplete }
  end

  def unconfirmed_locations_count
    locations.unconfirmed.size
  end
end
