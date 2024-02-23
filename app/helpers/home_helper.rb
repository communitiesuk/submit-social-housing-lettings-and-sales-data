module HomeHelper
  def data_count(user, type)
    years = FormHandler.instance.lettings_in_crossover_period? ? [current_collection_start_year, previous_collection_start_year] : [current_collection_start_year]

    if user.data_provider?
      case type
      when "lettings" then user.lettings_logs.where(created_by: user).where(status: %i[in_progress]).filter_by_years(years).count
      when "sales" then user.sales_logs.where(created_by: user).where(status: %i[in_progress]).filter_by_years(years).count
      when "misc" then user.lettings_logs.completed.where(created_by: user).count
      end
    else
      case type
      when "lettings" then user.lettings_logs.where(status: %i[in_progress]).filter_by_years(years).count
      when "sales" then user.sales_logs.where(status: %i[in_progress]).filter_by_years(years).count
      when "schemes" then user.schemes.incomplete.count
      end
    end
  end

  def heading_for_user_role(user)
    ROLE_HEADINGS[user.role]
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
    years = FormHandler.instance.lettings_in_crossover_period? ? [current_collection_start_year, previous_collection_start_year] : [current_collection_start_year]
    if user.data_provider?
      case type
      when "lettings" then lettings_logs_path(status: %i[in_progress], assigned_to: "you", years:, owning_organisation_select: "all", managing_organisation_select: "all")
      when "sales" then sales_logs_path(status: %i[in_progress], assigned_to: "you", years:, owning_organisation_select: "all", managing_organisation_select: "all")
      when "misc" then lettings_logs_path(status: [:completed], assigned_to: "you", years: [""], owning_organisation_select: "all", managing_organisation_select: "all")
      end
    else
      case type
      when "lettings" then lettings_logs_path(status: %i[in_progress], assigned_to: "all", years:, owning_organisation_select: "all", managing_organisation_select: "all")
      when "sales" then sales_logs_path(status: %i[in_progress], assigned_to: "all", years:, owning_organisation_select: "all", managing_organisation_select: "all")
      when "schemes" then schemes_path(status: [:incomplete], owning_organisation_select: "all")
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

  ROLE_HEADINGS = {
    "data_provider" => "Complete your logs",
    "data_coordinator" => "Manage your data",
    "support" => "Manage all data",
  }.freeze
end
