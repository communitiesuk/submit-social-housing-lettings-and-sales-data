module SchemesHelper
  def display_scheme_attributes(scheme, user)
    base_attributes = [
      { name: "Scheme code", value: scheme.id_to_display },
      { name: "Name", value: scheme.service_name, edit: true },
      { name: "Confidential information", value: scheme.sensitive, edit: true },
      { name: "Type of scheme", value: scheme.scheme_type },
      { name: "Registered under Care Standards Act 2000", value: scheme.registered_under_care_act },
      { name: "Housing stock owned by", value: scheme.owning_organisation.name, edit: true },
      { name: "Support services provided by", value: scheme.arrangement_type },
      { name: "Organisation providing support", value: scheme.managing_organisation&.name },
      { name: "Primary client group", value: scheme.primary_client_group },
      { name: "Has another client group", value: scheme.has_other_client_group },
      { name: "Secondary client group", value: scheme.secondary_client_group },
      { name: "Level of support given", value: scheme.support_type },
      { name: "Intended length of stay", value: scheme.intended_stay },
      { name: "Availability", value: scheme_availability(scheme) },
    ]

    if FeatureToggle.scheme_toggle_enabled?
      base_attributes.append({ name: "Status", value: status_tag(scheme.status) })
    end

    if user.data_coordinator?
      base_attributes.delete_if { |item| item[:name] == "Housing stock owned by" }
    end

    if scheme.arrangement_type_same?
      base_attributes.delete_if { |item| item[:name] == "Organisation providing support" }
    end
    base_attributes
  end

  def scheme_availability(scheme)
    availability = ""
    scheme_active_periods(scheme).each do |period|
      if period.from.present?
        availability << "\nActive from #{period.from.to_formatted_s(:govuk_date)}"
        availability << " to #{(period.to - 1.day).to_formatted_s(:govuk_date)}\nDeactivated on #{period.to.to_formatted_s(:govuk_date)}" if period.to.present?
      end
    end
    availability.strip
  end

  def toggle_scheme_link(scheme)
    return govuk_button_link_to "Deactivate this scheme", scheme_new_deactivation_path(scheme), warning: true if scheme.active?
    return govuk_button_link_to "Reactivate this scheme", scheme_new_reactivation_path(scheme) if scheme.deactivated?
  end

private

  ActivePeriod = Struct.new(:from, :to)
  def scheme_active_periods(scheme)
    periods = [ActivePeriod.new(scheme.available_from, nil)]

    sorted_deactivation_periods = remove_nested_periods(scheme.scheme_deactivation_periods.sort_by(&:deactivation_date))
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
