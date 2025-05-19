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

  def display_organisation_attributes(user, organisation)
    attributes = [
      { name: "Organisation ID", value: "ORG#{organisation.id}", editable: false },
      { name: "Address", value: organisation.address_string, editable: true },
      { name: "Telephone number", value: organisation.phone, editable: true },
      { name: "Registration number", value: organisation.housing_registration_no || "", editable: false },
      { name: "Type of provider", value: organisation.display_provider_type, editable: false },
      { name: "Owns housing stock", value: organisation.holds_own_stock ? "Yes" : "No", editable: false },
      { name: "Part of group", value: organisation.group_member ? "Yes" : "No", editable: user.support? },
    ]

    if organisation.group_member
      attributes << { name: "Group number", value: "GROUP#{organisation.group}", editable: user.support? }
    end

    attributes << { name: "For profit", value: organisation.display_profit_status, editable: user.support? }
    attributes << { name: "Rent periods", value: organisation.rent_period_labels, editable: true, format: :bullet }
    attributes << { name: "Data Sharing Agreement" }
    attributes << { name: "Status", value: status_tag(organisation.status) + delete_organisation_text(organisation), editable: false }

    attributes
  end

  def organisation_name_row(user:, organisation:, summary_list:)
    summary_list.with_row do |row|
      row.with_key { "Name" }
      row.with_value { organisation.name }
      if user.support?
        row.with_action(
          visually_hidden_text: organisation.name.humanize.downcase,
          href: change_name_organisation_path(organisation),
          html_attributes: { "data-qa": "change-#{organisation.name.downcase}" },
        )
      else
        row.with_action
      end
    end
  end

  def delete_organisation_text(organisation)
    if organisation.active == false && current_user.support? && !OrganisationPolicy.new(current_user, organisation).delete?
      "<div class=\"app-!-colour-muted\">This organisation was active in an open or editable collection year, and cannot be deleted.</div>".html_safe
    end
  end

  def rent_periods_with_checked_attr(checked_periods: nil)
    RentPeriod.rent_period_mappings.each_with_object({}) do |(period_code, period_value), result|
      result[period_code] = period_value.merge(checked: checked_periods.nil? || checked_periods.include?(period_code))
    end
  end

  def delete_organisation_link(organisation)
    govuk_button_link_to "Delete this organisation", delete_confirmation_organisation_path(organisation), warning: true
  end

  def organisation_action_text(attr, organisation)
    return "" if attr[:value].blank? || (attr[:attribute] == "phone" && organisation.phone.blank?)

    "Change"
  end

  def organisation_details_link_message(attribute)
    text = lowercase_first_letter(attribute[:name])
    return "Add #{text}" if attribute[:name] == "Rent periods"
    return "Select profit status" if attribute[:name] == "For profit"

    "Enter #{text}"
  end

  def group_organisation_options
    null_option = [OpenStruct.new(id: "", name: "Select an option", group: nil)]
    organisations = Organisation.visible.map { |org| OpenStruct.new(id: org.id, name: group_organisation_options_name(org)) }
    null_option + organisations
  end

  def group_organisation_options_name(org)
    "#{org.name}#{group_organisation_options_group_text(org)}"
  end

  def group_organisation_options_group_text(org)
    return "" unless org.oldest_group_member

    " (GROUP#{org.oldest_group_member&.group})"
  end

  def profit_status_options(provider_type = nil)
    null_option = [OpenStruct.new(id: "", name: "Select an option")]
    profit_statuses = Organisation::PROFIT_STATUS.map do |key, _value|
      OpenStruct.new(id: key, name: Organisation::DISPLAY_PROFIT_STATUS[key])
    end

    case provider_type
    when "LA"
      profit_statuses.select! { |option| option.id == :local_authority }
    when "PRP"
      profit_statuses.reject! { |option| option.id == :local_authority }
    end

    null_option + profit_statuses
  end
end
