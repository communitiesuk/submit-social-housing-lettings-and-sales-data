class LettingsLogsFiltersController < ApplicationController
  before_action :lettings_session_filters, if: :current_user
  before_action -> { lettings_filter_manager.serialize_filters_to_session }, if: :current_user
  before_action :authenticate_user!

  %w[years status needstype assigned_to owned_by managed_by].each do |filter|
    define_method(filter) do
      @filter_type = "lettings_logs"
      @filter = filter
      render "filters/#{filter}"
    end
  end

  %w[status needstype assigned_to owned_by managed_by].each do |filter|
    define_method("update_#{filter}") do
      @filter_type = "lettings_logs"

      redirect_to csv_download_lettings_logs_path(search: params["search"], codes_only: params["codes_only"])
    end
  end

  def update_years
    @filter_type = "lettings_logs"
    if params["years"].nil?
      redirect_to filters_years_lettings_logs_path(search: params["search"], codes_only: params["codes_only"], error: "Please select a year")
    else
      redirect_to csv_download_lettings_logs_path(search: params["search"], codes_only: params["codes_only"])
    end
  end
end

private

def lettings_session_filters
  params["years"] = [params["years"]] if params["years"].present?
  lettings_filter_manager.session_filters
end

def lettings_filter_manager
  FilterManager.new(current_user:, session:, params:, filter_type: "lettings_logs")
end
