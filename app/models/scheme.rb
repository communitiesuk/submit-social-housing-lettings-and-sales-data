class Scheme < ApplicationRecord
  belongs_to :owning_organisation, class_name: "Organisation"
  belongs_to :managing_organisation, optional: true, class_name: "Organisation"
  has_many :locations
  has_many :case_logs

  scope :filter_by_id, ->(id) { where(id: (id.start_with?("S") ? id[1..] : id)) }
  scope :search_by_service_name, ->(name) { where("service_name ILIKE ?", "%#{name}%") }
  scope :search_by_postcode, ->(postcode) { joins("LEFT JOIN locations ON locations.scheme_id = schemes.id").where("locations.postcode ILIKE ?", "%#{postcode.delete(' ')}%") }
  scope :search_by, ->(param) { search_by_postcode(param).or(search_by_service_name(param)).or(filter_by_id(param)).distinct }

  validate :validate_confirmed

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
    "Another registered housing provider": "R",
    "A registered charity or voluntary organisation": "V",
    "Another organisation": "O",
    "Missing": "X",
  }.freeze

  enum arrangement_type: ARRANGEMENT_TYPE, _suffix: true

  def id_to_display
    "S#{id}"
  end

  def check_details_attributes
    [
      { name: "Service code", value: id_to_display, id: "id" },
      { name: "Name", value: service_name, id: "service_name" },
      { name: "Confidential information", value: sensitive, id: "sensitive" },
      { name: "Type of scheme", value: scheme_type, id: "scheme_type" },
      { name: "Registered under Care Standards Act 2000", value: registered_under_care_act, id: "registered_under_care_act" },
      { name: "Housing stock owned by", value: owning_organisation.name, id: "owning_organisation_id" },
      { name: "Support services provided by", value: arrangement_type, id: "arrangement_type" },
    ]
  end

  def check_support_services_provider_attributes
    [
      { name: "Organisation providing support", value: managing_organisation&.name, id: "managing_organisation_id" },
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

  def display_attributes
    base_attributes = [
      { name: "Scheme code", value: id_to_display },
      { name: "Name", value: service_name, edit: true },
      { name: "Confidential information", value: sensitive, edit: true },
      { name: "Type of scheme", value: scheme_type },
      { name: "Registered under Care Standards Act 2000", value: registered_under_care_act },
      { name: "Housing stock owned by", value: owning_organisation.name, edit: true },
      { name: "Support services provided by", value: arrangement_type },
      { name: "Organisation providing support", value: managing_organisation&.name },
      { name: "Primary client group", value: primary_client_group },
      { name: "Has another client group", value: has_other_client_group },
      { name: "Secondary client group", value: secondary_client_group },
      { name: "Level of support given", value: support_type },
      { name: "Intended length of stay", value: intended_stay },
    ]

    if arrangement_type_same?
      base_attributes.delete({ name: "Organisation providing support", value: managing_organisation&.name })
    end
    base_attributes
  end

  def synonyms
    locations.map(&:postcode).join(",")
  end

  def appended_text
    "#{locations.count { |location| location.startdate.blank? || location.startdate <= Time.zone.today }} locations"
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

  def arrangement_type_same?
    arrangement_type.present? && ARRANGEMENT_TYPE[arrangement_type.to_sym] == "D"
  end

  def validate_confirmed
    required_attributes = attribute_names - %w[id created_at updated_at old_id old_visible_id confirmed end_date sensitive secondary_client_group total_units has_other_client_group]

    if confirmed == true
      required_attributes.any? do |attribute|
        if self[attribute].blank?
          errors.add attribute.to_sym
          self.confirmed = false
        end
      end
    end
  end
end
