module LocationsHelper
  def mobility_type_selection
    mobility_types_to_display = Location.mobility_types.excluding("Property designed to accessible general standard", "Missing")
    mobility_types_to_display.map { |key, value| OpenStruct.new(id: key, name: key.to_s.humanize, description: I18n.t("questions.descriptions.location.mobility_type.#{value}")) }
  end

  def another_location_selection
    selection_options(%w[Yes No])
  end

  def type_of_units_selection
    selection_options(Location.type_of_units)
  end

  def local_authorities_selection
    null_option = [OpenStruct.new(id: "", name: "Select an option")]
    null_option + Location.local_authorities.map { |code, name| OpenStruct.new(code:, name:) }
  end

  def selection_options(resource)
    return [] if resource.blank?

    resource.map { |key, _| OpenStruct.new(id: key, name: key.to_s.humanize) }
  end

  def display_location_attributes(location)
    [
      { name: "Postcode", value: location.postcode },
      { name: "Local authority", value: location.location_admin_district },
      { name: "Location name", value: location.name, edit: true },
      { name: "Total number of units at this location", value: location.units },
      { name: "Common type of unit", value: location.type_of_unit },
      { name: "Mobility type", value: location.mobility_type },
      { name: "Code", value: location.location_code },
      { name: "Availability", value: "Available from #{location.available_from.to_formatted_s(:govuk_date)}" },
      { name: "Status", value: location.status },
    ]
  end
end
