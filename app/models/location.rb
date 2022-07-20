class Location < ApplicationRecord
  validate :validate_postcode
  validates :units, :type_of_unit, presence: true
  belongs_to :scheme

  before_save :infer_la!, if: :postcode_changed?

  attr_accessor :add_another_location

  WHEELCHAIR_ADAPTATIONS = {
    Yes: 1,
    No: 2,
  }.freeze

  enum wheelchair_adaptation: WHEELCHAIR_ADAPTATIONS

  MOBILITY_TYPE = {
    "Property fitted with equipment and adaptations (if not designed to above standards)": "A",
    "Property designed to accessible general standard": "M",
    "None": "N",
    "Property designed to wheelchair user standard": "W",
    "Missing": "X",
  }.freeze

  enum mobility_type: MOBILITY_TYPE

  TYPE_OF_UNIT = {
    "Bungalow": 6,
    "Self-contained flat or bedsit": 1,
    "Self-contained flat or bedsit with common facilities": 2,
    "Self-contained house": 7,
    "Shared flat": 3,
    "Shared house or hostel": 4,
  }.freeze

  enum type_of_unit: TYPE_OF_UNIT

  def display_attributes
    [
      { name: "Location code ", value: location_code, suffix: false },
      { name: "Postcode", value: postcode, suffix: county },
      { name: "Type of unit", value: type_of_unit, suffix: false },
      { name: "Type of building", value: type_of_building, suffix: false },
      { name: "Wheelchair adaptation", value: wheelchair_adaptation, suffix: false },
    ]
  end

private

  PIO = PostcodeService.new

  def validate_postcode
    if postcode.nil? || !postcode&.match(POSTCODE_REGEXP)
      error_message = I18n.t("validations.postcode")
      errors.add :postcode, error_message
    end
  end

  def infer_la!
    self.location_code = PIO.infer_la(postcode)
  end
end
