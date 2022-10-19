module NavigationItemsHelper
  NavigationItem = Struct.new(:text, :href, :current, :classes)

  def primary_items(path, current_user)
    items = if current_user.support?
      [
        NavigationItem.new("Organisations", organisations_path, organisations_current?(path)),
        NavigationItem.new("Users", "/users", users_current?(path)),
        NavigationItem.new("Lettings logs", lettings_logs_path, lettings_logs_current?(path)),
        FeatureToggle.sales_log_enabled? ? NavigationItem.new("Sales logs", sales_logs_path, sales_logs_current?(path)) : nil,
        NavigationItem.new("Schemes", "/schemes", supported_housing_schemes_current?(path)),
      ].compact
    elsif current_user.data_coordinator? && current_user.organisation.holds_own_stock?
      [
        NavigationItem.new("Lettings logs", lettings_logs_path, lettings_logs_current?(path)),
        FeatureToggle.sales_log_enabled? ? NavigationItem.new("Sales logs", sales_logs_path, sales_logs_current?(path)) : nil,
        NavigationItem.new("Schemes", "/schemes", subnav_supported_housing_schemes_path?(path)),
        NavigationItem.new("Users", users_organisation_path(current_user.organisation), subnav_users_path?(path)),
        NavigationItem.new("About your organisation", "/organisations/#{current_user.organisation.id}", subnav_details_path?(path)),
      ].compact
    else
      [
        NavigationItem.new("Lettings logs", lettings_logs_path, lettings_logs_current?(path)),
        FeatureToggle.sales_log_enabled? ? NavigationItem.new("Sales logs", sales_logs_path, sales_logs_current?(path)) : nil,
        NavigationItem.new("Users", users_organisation_path(current_user.organisation), subnav_users_path?(path)),
        NavigationItem.new("About your organisation", "/organisations/#{current_user.organisation.id}", subnav_details_path?(path)),
        NavigationItem.new("Housing providers", housing_providers_organisation_path(current_user.organisation), housing_providers_current?(path)),
      ].compact
    end

    # figure out correct rules
    items << managing_agents_item(path)
  end

  def secondary_items(path, current_organisation_id)
    if current_user.organisation.holds_own_stock?
      [
        NavigationItem.new("Lettings logs", "/organisations/#{current_organisation_id}/lettings-logs", subnav_lettings_logs_path?(path)),
        FeatureToggle.sales_log_enabled? ? NavigationItem.new("Sales logs", "/organisations/#{current_organisation_id}/sales-logs", subnav_sales_logs_path?(path)) : nil,
        NavigationItem.new("Schemes", "/organisations/#{current_organisation_id}/schemes", subnav_supported_housing_schemes_path?(path)),
        NavigationItem.new("Users", "/organisations/#{current_organisation_id}/users", subnav_users_path?(path)),
        NavigationItem.new("About this organisation", "/organisations/#{current_organisation_id}", subnav_details_path?(path)),
      ].compact
    else
      [
        NavigationItem.new("Lettings logs", "/organisations/#{current_organisation_id}/lettings-logs", subnav_lettings_logs_path?(path)),
        FeatureToggle.sales_log_enabled? ? NavigationItem.new("Sales logs", "/organisations/#{current_organisation_id}/sales-logs", subnav_sales_logs_path?(path)) : nil,
        NavigationItem.new("Users", "/organisations/#{current_organisation_id}/users", subnav_users_path?(path)),
        NavigationItem.new("About this organisation", "/organisations/#{current_organisation_id}", subnav_details_path?(path)),
        NavigationItem.new("Housing providers", housing_providers_organisation_path, subnav_housing_providers_path?(path)),
      ].compact
    end
  end

  def scheme_items(path, current_scheme_id, title)
    [
      NavigationItem.new("Scheme", "/schemes/#{current_scheme_id}", !path.include?("locations")),
      NavigationItem.new(title, "/schemes/#{current_scheme_id}/locations", path.include?("locations")),
    ]
  end

private

  def lettings_logs_current?(path)
    path == "/lettings-logs"
  end

  def sales_logs_current?(path)
    path == "/sales-logs"
  end

  def users_current?(path)
    path == "/users" || path.include?("/users/")
  end

  def supported_housing_schemes_current?(path)
    path == "/schemes" || path.include?("/schemes/")
  end

  def organisations_current?(path)
    path == "/organisations" || path.include?("/organisations/")
  end

  def housing_providers_current?(path)
    path == "/housing-providers"
  end

  def subnav_housing_providers_path?(path)
    path.include?("/organisations") && path.include?("/housing-providers")
  end

  def subnav_supported_housing_schemes_path?(path)
    path.include?("/organisations") && path.include?("/schemes") || path.include?("/schemes/")
  end

  def subnav_users_path?(path)
    (path.include?("/organisations") && path.include?("/users")) || path.include?("/users/")
  end

  def subnav_lettings_logs_path?(path)
    path.include?("/organisations") && path.include?("/lettings-logs")
  end

  def subnav_sales_logs_path?(path)
    path.include?("/organisations") && path.include?("/sales-logs")
  end

  def subnav_details_path?(path)
    path.include?("/organisations") && path.include?("/details")
  end

  def managing_agents_path?(path)
    path.include?("/managing-agents")
  end

  def managing_agents_item(path)
    return unless FeatureToggle.managing_agents_enabled?
    return unless current_user.organisation.holds_own_stock?

    NavigationItem.new(
      "Managing agents",
      "/organisations/#{current_user.organisation.id}/managing-agents",
      managing_agents_path?(path),
    )
  end
end
