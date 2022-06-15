class Location < ApplicationRecord
  belongs_to :scheme

  WHEELCHAIR_ADAPTATION = {
    0 => "No",
    1 => "Yes",
  }.freeze

  def display_attributes
    [
      { name: "Location code ", value: location_code, suffix: false },
      { name: "Postcode", value: postcode, suffix: county },
      { name: "Type of unit", value: type_of_unit, suffix: false },
      { name: "Type of building", value: type_of_building, suffix: false },
      { name: "Wheelchair adaptation", value: wheelchair_adaptation_display, suffix: false },
    ]
  end

  def wheelchair_adaptation_display
    WHEELCHAIR_ADAPTATION[wheelchair_adaptation]
  end
end
