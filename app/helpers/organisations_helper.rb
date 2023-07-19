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
      { name: "Name", value: organisation.name, editable: true },
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
end
