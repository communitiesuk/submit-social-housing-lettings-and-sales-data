module TabNavHelper
  include GovukLinkHelper

  def user_cell(user)
    link_text = user.name.presence || user.email
    [govuk_link_to(link_text, user, class: "govuk-!-font-weight-bold"), user.email].join("\n")
  end

  def org_cell(user)
    role = "<span class='app-!-colour-muted'>#{user.role.to_s.humanize}</span>"
    [user.organisation.name, role].join("\n")
  end

  def tab_items(user)
    [
      { name: t("Details"), url: details_organisation_path(user.organisation) },
      { name: t("Users"), url: users_organisation_path(user.organisation) },
    ]
  end
end
