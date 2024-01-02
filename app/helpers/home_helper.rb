module HomeHelper

  def in_progress_count(user, type)
    case type
    when "lettings" then user.lettings_logs.in_progress.count
    when "sales" then user.sales_logs.in_progress.count
    when "schemes" then user.schemes.incomplete.count
    end
  end

  def heading_for_user_role(user)
    case user.role
    when "data_provider" then "Complete your logs"
    when "data_coordinator" then "Manage your data"
    when "support" then "Manage all data"
    end
  end

  def in_progress_subheading(user, type)
    if type == "schemes"
      return"Incomplete schemes"
    end
    "#{user.role == "data_provider" ? :"Your " : nil}#{type} in progress".capitalize
  end

  def in_progress_path(type)
    case type
    when "lettings" then lettings_logs_path(status: [:in_progress])
    when "sales" then sales_logs_path(status: [:in_progress])
    when "schemes" then schemes_path(status: [:incomplete])
    end
  end

  def clear_filter_path_for_type(type)
    case type
    when "lettings" then clear_filters_path(filter_type: "lettings_logs")
    when "sales" then clear_filters_path(filter_type: "sales_logs")
    when "schemes" then clear_filters_path(filter_type: "schemes")
    end
  end
end
