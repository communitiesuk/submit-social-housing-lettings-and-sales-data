module OrganisationsHelper
  def organisation_header(path, user, current_organisation)
    if path == "/organisations"
      "Organisations"
    elsif user.organisation_id == current_organisation.id
      "Your organisation"
    else
      current_organisation.name
    end
  end

  def display_organisation_attributes(organisation)
    [
      { name: "Organisation ID", value: "ORG#{organisation.id}", editable: false },
      { name: "Address", value: organisation.address_string, editable: true },
      { name: "Telephone number", value: organisation.phone, editable: true },
      { name: "Type of provider", value: organisation.display_provider_type, editable: false },
      { name: "Registration number", value: organisation.housing_registration_no || "", editable: false },
      { name: "Rent periods", value: organisation.rent_period_labels, editable: false, format: :bullet },
      { name: "Owns housing stock", value: organisation.holds_own_stock ? "Yes" : "No", editable: false },
      { name: "Status", value: status_tag(organisation.status), editable: false },
    ]
  end

  def organisation_name_row(user:, organisation:, summary_list:)
    summary_list.with_row do |row|
      row.with_key { "Name" }
      row.with_value { organisation.name }
      if user.support?
        row.with_action(
          visually_hidden_text: organisation.name.humanize.downcase,
          href: edit_organisation_path(organisation),
          html_attributes: { "data-qa": "change-#{organisation.name.downcase}" },
        )
      else
        row.with_action
      end
    end
  end

  def rent_periods_with_checked_attr(checked_periods: nil)
    all_rent_periods = RentPeriod.rent_period_mappings
    rent_periods = all_rent_periods.map do |code, period|
      period_copy = period.clone
      period_copy[:checked] = true if checked_periods.nil? || checked_periods.include?(code)
      [code, period_copy]
    end
    rent_periods.to_h
  end
end
