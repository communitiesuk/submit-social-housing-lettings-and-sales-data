class Scheme < ApplicationRecord
  before_create :create_code

  belongs_to :organisation
  has_many :locations
  has_many :case_logs

  scope :search_by_code, ->(code) { where("code ILIKE ?", "%#{code}%") }
  scope :search_by_service_name, ->(name) { where("service_name ILIKE ?", "%#{name}%") }
  scope :search_by_postcode, ->(postcode) { joins(:locations).where("locations.postcode ILIKE ?", "%#{postcode.delete(' ')}%") }
  scope :search_by, ->(param) { search_by_postcode(param).or(search_by_service_name(param)).or(search_by_code(param)).distinct }

  validates :organisation_id, presence: { message: I18n.t("validations.scheme.organisation_id_missing") }

  SENSITIVE = {
    No: 0,
    Yes: 1,
  }.freeze

  enum sensitive: SENSITIVE, _suffix: true

  REGISTERED_UNDER_CARE_ACT = {
    "No": 0,
    "Yes – registered care home providing nursing care": 1,
    "Yes – registered care home providing personal care": 2,
    "Yes – part registered as a care home": 3,
  }.freeze

  enum registered_under_care_act: REGISTERED_UNDER_CARE_ACT

  SCHEME_TYPE = {
    "Missing": 0,
    "Foyer": 4,
    "Direct Access Hostel": 5,
    "Other Supported Housing": 6,
    "Housing for older people": 7,
  }.freeze

  enum scheme_type: SCHEME_TYPE, _suffix: true

  SUPPORT_TYPE = {
    "Missing": 0,
    "Resettlement support": 1,
    "Low levels of support": 2,
    "Medium levels of support": 3,
    "High levels of care and support": 4,
    "Nursing care services to a care home": 5,
    "Floating Support": 6,
  }.freeze

  enum support_type: SUPPORT_TYPE, _suffix: true

  PRIMARY_CLIENT_GROUP = {
    "Homeless families with support needs": "O",
    "Offenders & people at risk of offending": "H",
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
    "Medium stay": "M",
    "Permanent": "P",
    "Short stay": "S",
    "Very short stay": "V",
    "Missing": "X",
  }.freeze

  HAS_OTHER_CLIENT_GROUP = {
    "Yes": "yes",
    "No": "no",
  }.freeze

  enum intended_stay: INTENDED_STAY, _suffix: true
  enum has_other_client_group: HAS_OTHER_CLIENT_GROUP, _suffix: true

  def check_details_attributes
    [
      { name: "Service code", value: code },
      { name: "Name", value: service_name },
      { name: "Confidential information", value: sensitive },
      { name: "Managed by", value: organisation.name },
      { name: "Type of scheme", value: scheme_type },
      { name: "Registered under Care Standards Act 2000", value: registered_under_care_act },
      { name: "Total number of units", value: total_units },
    ]
  end

  def check_primary_client_attributes
    [
      { name: "Primary client group", value: primary_client_group },
    ]
  end

  def check_secondary_client_confirmation_attributes
    [
      { name: "Has another client group", value: has_other_client_group },
    ]
  end

  def check_secondary_client_attributes
    [
      { name: "Secondary client group", value: secondary_client_group },
    ]
  end

  def check_support_attributes
    [
      { name: "Level of support given", value: support_type },
      { name: "Intended length of stay", value: intended_stay },
    ]
  end

  def display_attributes
    [
      { name: "Service code", value: code },
      { name: "Name", value: service_name },
      { name: "Confidential information", value: sensitive },
      { name: "Managed by", value: organisation.name },
      { name: "Type of scheme", value: scheme_type },
      { name: "Registered under Care Standards Act 2000", value: registered_under_care_act },
      { name: "Total number of units", value: total_units },
      { name: "Primary client group", value: primary_client_group },
      { name: "Secondary client group", value: secondary_client_group },
      { name: "Level of support given", value: support_type },
      { name: "Intended length of stay", value: intended_stay },
    ]
  end

private

  def create_code
    self.code = Scheme.last.nil? ? "S1" : "S#{Scheme.last.code[1..].to_i + 1}"
  end
end
