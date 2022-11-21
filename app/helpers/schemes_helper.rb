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
    availability = ""
    scheme.active_periods.each do |period|
      if period.from.present?
        availability << "\nActive from #{period.from.to_formatted_s(:govuk_date)}"
        availability << " to #{(period.to - 1.day).to_formatted_s(:govuk_date)}\nDeactivated on #{period.to.to_formatted_s(:govuk_date)}" if period.to.present?
      end
    end
    availability.strip
  end
end

