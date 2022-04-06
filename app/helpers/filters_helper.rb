module FiltersHelper
  def filter_selected?(filter)
    return true unless session[:case_logs_filters]

    selected_filters = JSON.parse(session[:case_logs_filters])
    selected_filters["status"].present? && selected_filters["status"].include?(filter.to_s)
  end

  def status_filters
    statuses = {}
    CaseLog.statuses.keys.map { |status| statuses[status] = status.humanize }
    statuses
  end
end
