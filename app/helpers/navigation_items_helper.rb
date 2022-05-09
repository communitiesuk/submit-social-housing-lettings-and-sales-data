module NavigationItemsHelper
  NavigationItem = Struct.new(:text, :href, :current, :classes)

  def primary_items(path, current_user)
    if current_user.support?
      [
        NavigationItem.new("Organisations", organisations_path, organisation_current?(path)),
        NavigationItem.new("Users", "/users", users_current?(path)),
        NavigationItem.new("Logs", case_logs_path, logs_current?(path)),
      ]
    else
      [
        NavigationItem.new("Logs", case_logs_path, logs_current?(path)),
        NavigationItem.new("Users", users_organisation_path(current_user.organisation), users_current?(path)),
        NavigationItem.new("About your organisation", "/organisations/#{current_user.organisation.id}", organisation_current?(path)),
      ]
    end
  end

private

  def logs_current?(path)
    path.include?("/logs")
  end

  def users_current?(path)
    path.include?("/users")
  end

  def organisation_current?(path)
    path.include?("/organisations") && !path.include?("/users")
  end
end
