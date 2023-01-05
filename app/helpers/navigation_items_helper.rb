module NavigationItemsHelper
  NavigationItem = Struct.new(:text, :href, :current, :classes)

  def primary_items(path, current_user)
    if current_user.support?
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
        (NavigationItem.new("Stock owners", stock_owners_organisation_path(current_user.organisation), stock_owners_path?(path)) if FeatureToggle.managing_owning_enabled?),
        (NavigationItem.new("Managing agents", managing_agents_organisation_path(current_user.organisation), managing_agents_path?(path)) if FeatureToggle.managing_owning_enabled?),
      ].compact
    else
      [
        NavigationItem.new("Lettings logs", lettings_logs_path, lettings_logs_current?(path)),
        FeatureToggle.sales_log_enabled? ? NavigationItem.new("Sales logs", sales_logs_path, sales_logs_current?(path)) : nil,
        NavigationItem.new("Users", users_organisation_path(current_user.organisation), subnav_users_path?(path)),
        NavigationItem.new("About your organisation", "/organisations/#{current_user.organisation.id}", subnav_details_path?(path)),
        (NavigationItem.new("Stock owners", stock_owners_organisation_path(current_user.organisation), stock_owners_path?(path)) if FeatureToggle.managing_owning_enabled?),
        (NavigationItem.new("Managing agents", managing_agents_organisation_path(current_user.organisation), managing_agents_path?(path)) if FeatureToggle.managing_owning_enabled?),
      ].compact
    end
  end

  def secondary_items(path, current_organisation_id)
    if current_user.organisation.holds_own_stock?
      [
        NavigationItem.new("Lettings logs", "/organisations/#{current_organisation_id}/lettings-logs", subnav_lettings_logs_path?(path)),
        FeatureToggle.sales_log_enabled? ? NavigationItem.new("Sales logs", "/organisations/#{current_organisation_id}/sales-logs", subnav_sales_logs_path?(path)) : nil,
        NavigationItem.new("Schemes", "/organisations/#{current_organisation_id}/schemes", subnav_supported_housing_schemes_path?(path)),
        NavigationItem.new("Users", "/organisations/#{current_organisation_id}/users", subnav_users_path?(path)),
        NavigationItem.new("About this organisation", "/organisations/#{current_organisation_id}", subnav_details_path?(path)),
        (NavigationItem.new("Stock owners", stock_owners_organisation_path(current_organisation_id), stock_owners_path?(path)) if FeatureToggle.managing_owning_enabled?),
        (NavigationItem.new("Managing agents", managing_agents_organisation_path(current_organisation_id), managing_agents_path?(path)) if FeatureToggle.managing_owning_enabled?),
      ].compact
    else
      [
        NavigationItem.new("Lettings logs", "/organisations/#{current_organisation_id}/lettings-logs", subnav_lettings_logs_path?(path)),
        FeatureToggle.sales_log_enabled? ? NavigationItem.new("Sales logs", "/organisations/#{current_organisation_id}/sales-logs", sales_logs_current?(path)) : nil,
        NavigationItem.new("Users", "/organisations/#{current_organisation_id}/users", subnav_users_path?(path)),
        NavigationItem.new("About this organisation", "/organisations/#{current_organisation_id}", subnav_details_path?(path)),
        (NavigationItem.new("Stock owners", stock_owners_organisation_path(current_organisation_id), stock_owners_path?(path)) if FeatureToggle.managing_owning_enabled?),
        (NavigationItem.new("Managing agents", managing_agents_organisation_path(current_organisation_id), managing_agents_path?(path)) if FeatureToggle.managing_owning_enabled?),
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
    path.starts_with?("/lettings-logs")
  end

  def sales_logs_current?(path)
    path.starts_with?("/sales-logs")
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

  def stock_owners_path?(path)
    path.include?("/stock-owners")
  end

  def managing_agents_path?(path)
    path.include?("/managing-agents")
  end
end
