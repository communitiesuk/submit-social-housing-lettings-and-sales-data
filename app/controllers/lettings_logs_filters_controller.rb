class LettingsLogsFiltersController < ApplicationController
  before_action :session_filters, if: :current_user, only: %i[update]
  before_action -> { filter_manager.serialize_filters_to_session }, if: :current_user, only: %i[update]

  %w[years status needstype assigned_to owned_by managed_by].each do |filter|
    define_method(filter) do
      @filter_form = Forms::FilterForm.new
      @filter_type = "lettings_logs"
      @search_term = params["search"]
      @codes_only = params["codes_only"]
      render "filters/lettings_log_filters/#{filter}"
    end
  end

  def update
    @filter_form = Forms::FilterForm.new(filter_form_params)
    @filter_type = "lettings_logs"
    @search_term = params["search"]
    @codes_only = params["codes_only"]

    if @filter_form.valid?
      session_filters
      redirect_to csv_download_lettings_logs_path(search: @search_term, codes_only: @codes_only)
    else
      render "filters/lettings_log_filters/years", status: :unprocessable_entity
    end
  end
end

private

def filter_form_params
  filter_params = params.permit(:years, :status, :needstypes, :assigned_to, :user, :owning_organisation_select, :owning_organisation, :managing_organisation_select, :managing_organisation)
  filter_params[:years] = session_filters["years"] if filter_params[:years].blank?
  filter_params
end

def session_filters
  params["forms_filter_form"].each { |key, value| params[key] = value } if params["forms_filter_form"].present?
  params["years"] = [params["years"]] if params["years"].present?
  filter_manager.session_filters
end

def filter_manager
  FilterManager.new(current_user:, session:, params:, filter_type: "lettings_logs")
end
