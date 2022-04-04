module FiltersHelper
  def filter_selected?(filter)
    return true unless cookies[:case_logs_filters]

    selected_filters = JSON.parse(cookies[:case_logs_filters])
    selected_filters["status"].present? && selected_filters["status"].include?(filter.to_s)
  end
end
