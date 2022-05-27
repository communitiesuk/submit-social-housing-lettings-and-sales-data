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
end
