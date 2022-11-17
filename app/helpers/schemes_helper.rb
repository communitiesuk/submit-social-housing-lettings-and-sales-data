module SchemesHelper
  def display_scheme_attributes(scheme)
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
      base_attributes.append({ name: "Status", value: scheme.status })
    end

    if scheme.arrangement_type_same?
      base_attributes.delete({ name: "Organisation providing support", value: scheme.managing_organisation&.name })
    end
    base_attributes
  end

  def scheme_availability(scheme)
    availability = "Active from #{scheme.available_from.to_formatted_s(:govuk_date)}"
    scheme.scheme_deactivation_periods.each do |deactivation|
      availability << " to #{(deactivation.deactivation_date - 1.day).to_formatted_s(:govuk_date)}\nDeactivated on #{deactivation.deactivation_date.to_formatted_s(:govuk_date)}"
      availability << "\nActive from #{deactivation.reactivation_date.to_formatted_s(:govuk_date)}" if deactivation.reactivation_date.present?
    end
    availability
  end
end
