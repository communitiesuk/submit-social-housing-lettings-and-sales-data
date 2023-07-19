module OrganisationHelper
  def organisation_header(path, user, current_organisation)
    if path == "/organisations"
      "Organisations"
    elsif user.organisation_id == current_organisation.id
      "Your organisation"
    else
      current_organisation.name
    end
  end

  def organisation_name_row(user:, organisation:, summary_list:)
    summary_list.row do |row|
      row.key { "Name" }
      row.value { organisation.name }
      if user.support?
        row.action(
          visually_hidden_text: organisation.name.humanize.downcase,
          href: edit_organisation_path(organisation),
          html_attributes: { "data-qa": "change-#{organisation.name.downcase}" },
        )
      else
        row.action
      end
    end
  end
end
