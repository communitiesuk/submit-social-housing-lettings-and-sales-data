module FiltersHelper
  def filter_selected?(filter, value)
    return false unless session[:case_logs_filters]

    selected_filters = JSON.parse(session[:case_logs_filters])
    return true if selected_filters.blank? && filter == "user" && value == :all
    return true if !selected_filters.key?("organisation") && filter == "organisation_select" && value == :all
    return true if selected_filters["organisation"].present? && filter == "organisation_select" && value == :specific_org
    return false if selected_filters[filter].blank?

    selected_filters[filter].include?(value.to_s)
  end

  def status_filters
    statuses = {}
    CaseLog.statuses.keys.map { |status| statuses[status] = status.humanize }
    statuses
  end

  def selected_option(filter)
    return false unless session[:case_logs_filters]

    JSON.parse(session[:case_logs_filters])[filter]
  end
end
