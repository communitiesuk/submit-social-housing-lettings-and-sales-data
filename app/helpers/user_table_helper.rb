module UserTableHelper
  include GovukLinkHelper

  def user_cell(user)
    [govuk_link_to(user.name, user), user.email].join("\n")
  end

  def org_cell(user)
    role = "<span class='app-!-colour-muted'>#{user.role.to_s.humanize}</span>"
    [user.organisation.name, role].join("\n")
  end
end
