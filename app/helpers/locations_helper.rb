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
      { name: "Postcode", value: location.postcode, attribute: "postcode" },
      { name: "Location name", value: location.name, attribute: "name" },
      { name: "Local authority", value: location.location_admin_district, attribute: "location_admin_district" },
      { name: "Number of units", value: location.units, attribute: "units" },
      { name: "Most common unit", value: location.type_of_unit, attribute: "type_of_unit"},
      { name: "Mobility standards", value: location.mobility_type, attribute: "mobility_standards" },
      { name: "Code", value: location.location_code, attribute: "location_code" },
      { name: "Availability", value: location_availability(location), attribute: "startdate" },
    ]

    if FeatureToggle.location_toggle_enabled?
      base_attributes.append({ name: "Status", value: location.status, attribute: "status" })
    end

    base_attributes
  end

  def location_availability(location)
    availability = ""
    location_active_periods(location).each do |period|
      if period.from.present?
        availability << "\nActive from #{period.from.to_formatted_s(:govuk_date)}"
        availability << " to #{(period.to - 1.day).to_formatted_s(:govuk_date)}\nDeactivated on #{period.to.to_formatted_s(:govuk_date)}" if period.to.present?
      end
    end
    availability.strip
  end

  def location_edit_path(location, page)
    case page
    when "postcode"
      scheme_location_postcode_path(location.scheme, location, referrer: "check_answers")
    when "name"
      scheme_location_name_path(location.scheme, location, referrer: "check_answers")
    when "location_admin_district"
      scheme_location_edit_local_authority_path(location.scheme, location, referrer: "check_answers")
    when "units"
      scheme_location_units_path(location.scheme, location, referrer: "check_answers")
    when "type_of_unit"
      scheme_location_type_of_unit_path(location.scheme, location, referrer: "check_answers")
    when "mobility_standards"
      scheme_location_mobility_standards_path(location.scheme, location, referrer: "check_answers")
    when "startdate"
      scheme_location_startdate_path(location.scheme, location, referrer: "check_answers")
    end
  end

private

  ActivePeriod = Struct.new(:from, :to)
  def location_active_periods(location)
    periods = [ActivePeriod.new(location.available_from, nil)]

    sorted_deactivation_periods = remove_nested_periods(location.location_deactivation_periods.sort_by(&:deactivation_date))
    sorted_deactivation_periods.each do |deactivation|
      periods.last.to = deactivation.deactivation_date
      periods << ActivePeriod.new(deactivation.reactivation_date, nil)
    end

    remove_overlapping_and_empty_periods(periods)
  end

  def remove_overlapping_and_empty_periods(periods)
    periods.select { |period| period.from.present? && (period.to.nil? || period.from < period.to) }
  end

  def remove_nested_periods(periods)
    periods.select { |inner_period| periods.none? { |outer_period| is_nested?(inner_period, outer_period) } }
  end

  def is_nested?(inner, outer)
    return false if inner == outer
    return false if [inner.deactivation_date, inner.reactivation_date, outer.deactivation_date, outer.reactivation_date].any?(&:blank?)

    [inner.deactivation_date, inner.reactivation_date].all? { |date| date.between?(outer.deactivation_date, outer.reactivation_date) }
  end
end
