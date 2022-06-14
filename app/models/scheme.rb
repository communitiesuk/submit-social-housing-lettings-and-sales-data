class Scheme < ApplicationRecord
  belongs_to :organisation

  scope :search_by_code, ->(code) { where("code ILIKE ?", "%#{code}%") }
  scope :search_by_service_name, ->(name) { where("service_name ILIKE ?", "%#{name}%") }
  scope :search_by, ->(param) { search_by_code(param).or(search_by_service_name(param)) }

  SCHEME_TYPE = {
    0 => "Missings",
    4 => "Foyer",
    5 => "D, L, Airect Access Hostel",
    6 => "Other Supported Housing",
    7 => "Housing for older people",
  }.freeze

  PRIMARY_CLIENT_GROUP = {
    "O" => "Homeless families with support needs",
    "H" => "Offenders &amp; people at risk of offending",
    "M" => "Older people with support needs",
    "L" => "People at risk of domestic violence",
    "A" => "People with a physical or sensory disability",
    "G" => "People with alcohol problems",
    "F" => "People with drug problems",
    "B" => "People with HIV or AIDS",
    "D" => "People with learning disabilities",
    "E" => "People with mental health problems",
    "I" => "Refugees (permanent)",
    "S" => "Rough sleepers",
    "N" => "Single homeless people with support needs",
    "R" => "Teenage parents",
    "Q" => "Young people at risk",
    "P" => "Young people leaving care",
    "X" => "Missing",
  }.freeze

  SUPPORT_TYPE = {
    0 => "Missing",
    1 => "Resettlement Support",
    2 => "Low levels of support",
    3 => "Medium levels of support",
    4 => "High levels of care and support",
    5 => "Nursing care services to a care home",
    6 => "Floating Support",
  }.freeze

  INTENDED_STAY = {
    "M" =>"Medium stay",
    "P" =>"Permanent",
    "S" =>"Short Stay",
    "V" =>"Very short stay",
    "X" =>"Missing",
  }.freeze

  REGISTERED_UNDER_CARE_ACT = {
    0 => "Yes – part registered as a care home",
    1 => "No",
  }.freeze

  def display_attributes
    [
      { name: "Service code", value: code },
      { name: "Name", value: service_name },
      { name: "Confidential information", value: sensitive },
      { name: "Managing agent", value: organisation.name },
      { name: "Type of service", value: scheme_type_display },
      { name: "Registered under Care Standards Act 2000", value: registered_under_care_act_display },
      { name: "Total number of units", value: total_units },
      { name: "Primary client group", value: primary_client_group_display },
      { name: "Secondary client group", value: secondary_client_group_display },
      { name: "Level of support given", value: support_type_display },
      { name: "Intended length of stay", value: intended_stay_display },
    ]
  end

  def scheme_type_display
    SCHEME_TYPE[scheme_type]
  end

  def registered_under_care_act_display
    REGISTERED_UNDER_CARE_ACT[registered_under_care_act]
  end

  def primary_client_group_display
    PRIMARY_CLIENT_GROUP[primary_client_group]
  end

  def secondary_client_group_display
    PRIMARY_CLIENT_GROUP[secondary_client_group]
  end

  def support_type_display
    SUPPORT_TYPE[support_type]
  end

  def intended_stay_display
    INTENDED_STAY[intended_stay]
  end
end
