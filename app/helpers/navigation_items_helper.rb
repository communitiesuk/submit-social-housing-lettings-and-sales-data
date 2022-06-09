module NavigationItemsHelper
  NavigationItem = Struct.new(:text, :href, :current, :classes)

  def primary_items(path, current_user)
    if current_user.support?
      [
        NavigationItem.new("Organisations", organisations_path, organisations_current?(path)),
        NavigationItem.new("Users", "/users", users_current?(path)),
        NavigationItem.new("Logs", case_logs_path, logs_current?(path)),
        NavigationItem.new("Supported housing", "/supported-housing", supported_housing_current?(path)),
      ]
    elsif current_user.data_coordinator?
      [
        NavigationItem.new("Logs", case_logs_path, logs_current?(path)),
        NavigationItem.new("Supported housing", "/supported-housing", supported_housing_current?(path)),
        NavigationItem.new("Users", users_organisation_path(current_user.organisation), subnav_users_path?(path)),
        NavigationItem.new("About your organisation", "/organisations/#{current_user.organisation.id}", subnav_details_path?(path)),
      ]
    else
      [
        NavigationItem.new("Logs", case_logs_path, logs_current?(path)),
        NavigationItem.new("Users", users_organisation_path(current_user.organisation), subnav_users_path?(path)),
        NavigationItem.new("About your organisation", "/organisations/#{current_user.organisation.id}", subnav_details_path?(path)),
      ]
    end
  end

  def secondary_items(path, current_organisation_id)
    [
      NavigationItem.new("Logs", "/organisations/#{current_organisation_id}/logs", subnav_logs_path?(path)),
      NavigationItem.new("Users", "/organisations/#{current_organisation_id}/users", subnav_users_path?(path)),
      NavigationItem.new("About this organisation", "/organisations/#{current_organisation_id}", subnav_details_path?(path)),
    ]
  end

private

  def logs_current?(path)
    path == "/logs"
  end

  def users_current?(path)
    path == "/users"
  end

  def supported_housing_current?(path)
    path == "/supported-housing"
  end

  def organisations_current?(path)
    path == "/organisations" || subnav_users_path?(path) || subnav_logs_path?(path) || subnav_details_path?(path)
  end

  def subnav_users_path?(path)
    path.include?("/organisations") && path.include?("/users")
  end

  def subnav_logs_path?(path)
    path.include?("/organisations") && path.include?("/logs")
  end

  def subnav_details_path?(path)
    path.include?("/organisations") && path.include?("/details")
  end
end
