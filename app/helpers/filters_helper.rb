module FiltersHelper
  def filter_selected?(filter, value)
    return false unless session[:logs_filters]

    selected_filters = JSON.parse(session[:logs_filters])
    return true if selected_filters.blank? && filter == "user" && value == :all
    return true if !selected_filters.key?("organisation") && filter == "organisation_select" && value == :all
    return true if selected_filters["organisation"].present? && filter == "organisation_select" && value == :specific_org
    return false if selected_filters[filter].blank?

    selected_filters[filter].include?(value.to_s)
  end

  def status_filters
    {
      "not_started" => "Not started",
      "in_progress" => "In progress",
      "completed" => "Completed",
    }.freeze
  end

  def selected_option(filter)
    return false unless session[:logs_filters]

    JSON.parse(session[:logs_filters])[filter] || ""
  end

  def organisations_filter_options(user)
    organisation_options = user.support? ? Organisation.all : [user.organisation] + user.organisation.managing_agents
    [OpenStruct.new(id: "", name: "Select an option")] + organisation_options.map { |org| OpenStruct.new(id: org.id, name: org.name) }
  end

  def collection_year_options
    if FeatureToggle.collection_2023_2024_year_enabled?
      { "2023": "2023/24", "2022": "2022/23", "2021": "2021/22" }
    else
      { "2022": "2022/23", "2021": "2021/22" }
    end
  end
end
