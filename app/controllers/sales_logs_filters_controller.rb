class SalesLogsFiltersController < ApplicationController
  before_action :session_filters, if: :current_user
  before_action -> { filter_manager.serialize_filters_to_session }, if: :current_user

  %w[years status assigned_to owned_by managed_by].each do |filter|
    define_method(filter) do
      @filter_type = "sales_logs"
      @filter = filter
      render "filters/#{filter}"
    end
  end

  %w[status assigned_to owned_by managed_by].each do |filter|
    define_method("update_#{filter}") do
      @filter_type = "sales_logs"

      redirect_to csv_download_sales_logs_path(search: params["search"], codes_only: params["codes_only"])
    end
  end

  def update_years
    @filter_type = "sales_logs"
    if params["years"].nil?
      redirect_to filters_years_sales_logs_path(search: params["search"], codes_only: params["codes_only"], error: "Please select a year")
    else
      redirect_to csv_download_sales_logs_path(search: params["search"], codes_only: params["codes_only"])
    end
  end
end

private

def session_filters
  params["years"] = [params["years"]] if params["years"].present?
  filter_manager.session_filters
end

def filter_manager
  FilterManager.new(current_user:, session:, params:, filter_type: "sales_logs")
end
