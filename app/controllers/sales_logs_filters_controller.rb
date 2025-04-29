class SalesLogsFiltersController < ApplicationController
  before_action :sales_session_filters, if: :current_user
  before_action -> { sales_filter_manager.serialize_filters_to_session }, if: :current_user
  before_action :authenticate_user!

  %w[years status salestype assigned_to owned_by managed_by].each do |filter|
    define_method(filter) do
      @filter_type = "sales_logs"
      @filter = filter
      render "filters/#{filter}"
    end

    define_method("organisation_#{filter}") do
      @filter_type = "sales_logs"
      @organisation_id = params["id"]
      @filter = filter
      render "filters/#{filter}"
    end
  end

  %w[status salestype assigned_to owned_by managed_by].each do |filter|
    define_method("update_#{filter}") do
      @filter_type = "sales_logs"

      redirect_to csv_download_sales_logs_path(search: params["search"], codes_only: params["codes_only"])
    end

    define_method("update_organisation_#{filter}") do
      @organisation_id = params["id"]
      @filter_type = "sales_logs"

      redirect_to sales_logs_csv_download_organisation_path(params["id"], search: params["search"], codes_only: params["codes_only"])
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

  def update_organisation_years
    @filter_type = "sales_logs"
    @organisation_id = params["id"]
    if params["years"].nil?
      redirect_to sales_logs_filters_years_organisation_path(search: params["search"], codes_only: params["codes_only"], error: "Please select a year")
    else
      redirect_to sales_logs_csv_download_organisation_path(params["id"], search: params["search"], codes_only: params["codes_only"])
    end
  end
end

private

def sales_session_filters
  params["years"] = [params["years"]] if params["years"].present?
  sales_filter_manager.session_filters
end

def sales_filter_manager
  FilterManager.new(current_user:, session:, params:, filter_type: "sales_logs")
end
