module HomeHelper
  def data_count(user, type)
    if user.data_provider?
      case type
      when "lettings" then user.lettings_logs.in_progress.where(created_by: user).count
      when "sales" then user.sales_logs.in_progress.where(created_by: user).count
      when "misc" then user.lettings_logs.completed.where(created_by: user).count
      end
    else
      case type
      when "lettings" then user.lettings_logs.in_progress.count
      when "sales" then user.sales_logs.in_progress.count
      when "schemes" then user.schemes.incomplete.count
      end
    end
  end

  def heading_for_user_role(user)
    case user.role
    when "data_provider" then "Complete your logs"
    when "data_coordinator" then "Manage your data"
    when "support" then "Manage all data"
    end
  end

  def data_subheading(user, type)
    case type
    when "schemes"
      "Incomplete schemes"
    when "misc"
      "Your completed lettings"
    else
      "#{user.role == 'data_provider' ? :"Your " : nil}#{type} in progress".capitalize
    end
  end

  def data_path(user, type)
    if user.data_provider?
      case type
      when "lettings" then lettings_logs_path(status: [:in_progress], assigned_to: "you")
      when "sales" then sales_logs_path(status: [:in_progress], assigned_to: "you")
      when "misc" then lettings_logs_path(status: [:completed], assigned_to: "you")
      end
    else
      case type
      when "lettings" then lettings_logs_path(status: [:in_progress])
      when "sales" then sales_logs_path(status: [:in_progress])
      when "schemes" then schemes_path(status: [:incomplete])
      end
    end
  end

  def view_all_path(type)
    case type
    when "lettings" then clear_filters_path(filter_type: "lettings_logs")
    when "sales" then clear_filters_path(filter_type: "sales_logs")
    when "schemes" then clear_filters_path(filter_type: "schemes")
    when "misc" then clear_filters_path(filter_type: "schemes")
    end
  end

  def view_all_text(type)
    if type == "misc"
      "View all schemes"
    else
      "View all #{type}"
    end
  end
end
