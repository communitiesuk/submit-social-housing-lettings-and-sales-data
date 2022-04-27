module NavigationItemsHelper
  NavigationItem = Struct.new(:text, :href, :current, :classes)

  def primary_items(current_user)
    if current_user.support?
      [
        NavigationItem.new("Organisations", organisations_path, organisation_current?),
        NavigationItem.new("Users", users_path, users_current?),
        NavigationItem.new("Logs", case_logs_path, logs_current?),
      ]
    else
      [
        NavigationItem.new("Logs", case_logs_path, logs_current?),
        NavigationItem.new("Users", users_organisation_path(current_user.organisation), users_current?),
        NavigationItem.new("About your organisation", "/organisations/#{current_user.organisation.id}", organisation_current?),
      ]
    end
  end

private

  def current?(current_controller, controllers)
    current_controller.controller_name.in?(Array.wrap(controllers))
  end

  def current_action?(current_controller, action)
    current_controller.action_name == action
  end

  def logs_current?
    current?(controller, %w[case_logs form])
  end

  def users_current?
    current?(controller, %w[users]) || current_action?(controller, "users")
  end

  def organisation_current?
    current?(controller, %w[organisations]) && !current_action?(controller, "users")
  end
end
