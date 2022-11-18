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
    base_attributes = [
      { name: "Postcode", value: location.postcode },
      { name: "Local authority", value: location.location_admin_district },
      { name: "Location name", value: location.name, edit: true },
      { name: "Total number of units at this location", value: location.units },
      { name: "Common type of unit", value: location.type_of_unit },
      { name: "Mobility type", value: location.mobility_type },
      { name: "Code", value: location.location_code },
      { name: "Availability", value: location_availability(location) },
    ]

    if FeatureToggle.location_toggle_enabled?
      base_attributes.append({ name: "Status", value: location.status })
    end

    base_attributes
  end

  ActivePeriod = Struct.new(:from, :to)
  def location_availability(location)
    active_periods = [ActivePeriod.new(location.available_from, nil)]

    sorted_deactivation_periods = location.location_deactivation_periods.sort_by(&:deactivation_date)
    sorted_deactivation_periods.each do |deactivation|
      active_periods.find { |x| x.to.nil? }.to = deactivation.deactivation_date
      active_periods << ActivePeriod.new(deactivation.reactivation_date, nil)
    end

    filtered_active_periods = active_periods.select { |period| period.to.nil? || (period.from.present? && period.from <= period.to) }
    availability = ""
    filtered_active_periods.each do |period|
      if period.from.present?
        availability << "\nActive from #{period.from.to_formatted_s(:govuk_date)}"
        availability << " to #{(period.to - 1.day).to_formatted_s(:govuk_date)}\nDeactivated on #{period.to.to_formatted_s(:govuk_date)}" if period.to.present?
      end
    end
    availability.strip
  end
end
