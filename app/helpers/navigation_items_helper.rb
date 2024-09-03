module NavigationItemsHelper
  NavigationItem = Struct.new(:text, :href, :current, :classes)

  def primary_items(path, current_user)
    if current_user.support?
      [
        NavigationItem.new("Home", root_path, home_current?(path)),
        NavigationItem.new("Organisations", organisations_path, organisations_current?(path)),
        NavigationItem.new("Users", users_path, users_current?(path)),
        NavigationItem.new("Lettings logs", lettings_logs_path, lettings_logs_current?(path)),
        NavigationItem.new("Sales logs", sales_logs_path, sales_logs_current?(path)),
        NavigationItem.new("Schemes", schemes_path, supported_housing_schemes_current?(path)),
      ].compact
    else
      [
        NavigationItem.new("Home", root_path, home_current?(path)),
        NavigationItem.new("Lettings logs", lettings_logs_path, lettings_logs_current?(path)),
        NavigationItem.new("Sales logs", sales_logs_path, sales_logs_current?(path)),
        (NavigationItem.new("Schemes", schemes_path, non_support_supported_housing_schemes_current?(path)) if current_user.organisation.holds_own_stock? || current_user.organisation.stock_owners.present?),
        NavigationItem.new("Users", users_organisation_path(current_user.organisation), subnav_users_path?(path)),
        NavigationItem.new("Your organisation", details_organisation_path(current_user.organisation.id), subnav_details_path?(path)),
        NavigationItem.new("Stock owners", stock_owners_organisation_path(current_user.organisation), stock_owners_path?(path)),
        NavigationItem.new("Managing agents", managing_agents_organisation_path(current_user.organisation), managing_agents_path?(path)),
      ].compact
    end
  end

  def secondary_items(path, current_organisation_id)
    [
      NavigationItem.new("Lettings logs", lettings_logs_organisation_path(current_organisation_id), subnav_lettings_logs_path?(path)),
      NavigationItem.new("Sales logs", sales_logs_organisation_path(current_organisation_id), subnav_sales_logs_path?(path)),
      (NavigationItem.new("Schemes", schemes_organisation_path(current_organisation_id), subnav_supported_housing_schemes_path?(path)) if current_user.organisation.holds_own_stock? || current_user.organisation.stock_owners.present?),
      NavigationItem.new("Users", users_organisation_path(current_organisation_id), subnav_users_path?(path)),
      NavigationItem.new("About this organisation", details_organisation_path(current_organisation_id), subnav_details_path?(path)),
      NavigationItem.new("Stock owners", stock_owners_organisation_path(current_organisation_id), stock_owners_path?(path)),
      NavigationItem.new("Managing agents", managing_agents_organisation_path(current_organisation_id), managing_agents_path?(path)),
    ].compact
  end

  def scheme_items(path, current_scheme_id)
    [
      NavigationItem.new("Scheme", scheme_path(current_scheme_id), !path.include?("locations")),
      NavigationItem.new("Locations", scheme_locations_path(current_scheme_id), path.include?("locations")),
    ]
  end

private

  def home_current?(path)
    path == root_path || path.match?(/^\/notifications\/\d+$/)
  end

  def lettings_logs_current?(path)
    path.starts_with?(lettings_logs_path)
  end

  def sales_logs_current?(path)
    path.starts_with?(sales_logs_path)
  end

  def users_current?(path)
    path == users_path || path.include?("/users/")
  end

  def supported_housing_schemes_current?(path)
    path.starts_with?(schemes_path)
  end

  def non_support_supported_housing_schemes_current?(path)
    path.starts_with?(organisations_path) && path.include?("/schemes") || path.include?("/schemes/")
  end

  def organisations_current?(path)
    path == organisations_path || path.include?("/organisations/")
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
    path.include?("/organisations") && (path.include?("/details") || path.include?("/merge"))
  end

  def stock_owners_path?(path)
    path.include?("/stock-owners")
  end

  def managing_agents_path?(path)
    path.include?("/managing-agents")
  end
end
