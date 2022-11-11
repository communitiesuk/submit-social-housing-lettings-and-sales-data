module SchemesHelper
  def display_attributes(scheme)
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
      { name: "Availability", value: "Available from #{scheme.available_from.to_formatted_s(:govuk_date)}"},
      { name: "Status", value: scheme.status },
    ]

    if scheme.arrangement_type_same?
      base_attributes.delete({ name: "Organisation providing support", value: scheme.managing_organisation&.name })
    end
    base_attributes
  end

  def availability_text(scheme)
    base_text = "Available from #{scheme.available_from.to_formatted_s(:govuk_date)}"
    if scheme.deactivation_date.present?
      base_text += "\nDeactivation date #{scheme.deactivation_date.to_formatted_s(:govuk_date)}"
    end
    base_text
  end

  def scheme_status(scheme)
    now = Time.zone.now
    if scheme.deactivation_date.nil?
      "active"
    elsif scheme.deactivation_date < now
      "deactivated"
    elsif now < scheme.deactivation_date
      "deactivates_soon"
    end
  end
end
