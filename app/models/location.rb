class Location < ApplicationRecord
  belongs_to :scheme

  WHEELCHAIR_ADAPTATIONS = {
    No: 0,
    Yes: 1,
  }.freeze

  enum wheelchair_adaptation: WHEELCHAIR_ADAPTATIONS

  def display_attributes
    [
      { name: "Location code ", value: location_code, suffix: false },
      { name: "Postcode", value: postcode, suffix: county },
      { name: "Type of unit", value: type_of_unit, suffix: false },
      { name: "Type of building", value: type_of_building, suffix: false },
      { name: "Wheelchair adaptation", value: wheelchair_adaptation, suffix: false },
    ]
  end
end
