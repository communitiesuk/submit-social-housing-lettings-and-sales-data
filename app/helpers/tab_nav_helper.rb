module TabNavHelper
  include GovukLinkHelper
  include Helpers

  def user_cell(user)
    link_text = user.name.presence || user.email
    [govuk_link_to(link_text, user), "<span class=\"govuk-visually-hidden\">User </span><span class=\"govuk-!-font-weight-regular app-!-colour-muted\">#{user.email}</span>"].join("\n")
  end

  def location_cell(location, link)
    link_text = location.postcode.formatted_postcode
    [govuk_link_to(link_text, link, method: :patch), "<span class=\"govuk-visually-hidden\">Location </span><span class=\"govuk-!-font-weight-regular app-!-colour-muted\">#{location.name}</span>"].join("\n")
  end

  def scheme_cell(scheme)
    link_text = scheme.service_name
    [govuk_link_to(link_text, scheme), "<span class=\"govuk-visually-hidden\">Scheme </span><span class=\"govuk-!-font-weight-regular app-!-colour-muted\">#{scheme.primary_client_group}</span>"].join("\n")
  end

  def org_cell(user)
    role = "<span class=\"app-!-colour-muted\">#{user.role.to_s.humanize}</span>"
    [user.organisation.name, role].join("\n")
  end

  def tab_items(user)
    [
      { name: t("Details"), url: details_organisation_path(user.organisation) },
      { name: t("Users"), url: users_organisation_path(user.organisation) },
    ]
  end
end
