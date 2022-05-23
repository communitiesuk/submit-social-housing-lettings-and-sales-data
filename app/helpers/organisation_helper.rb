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

  DISPLAY_PROVIDER_TYPE = { "LA": "Local authority", "PRP": "Private registered provider" }.freeze
  def display_provider_type(provider_type)
    DISPLAY_PROVIDER_TYPE[provider_type.to_sym]
  end
end
