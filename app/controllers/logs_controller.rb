class LogsController < ApplicationController

  include Pagy::Backend
  include Modules::LogsFilter
  include Modules::SearchFilter

  skip_before_action :verify_authenticity_token, if: :json_api_request?
  before_action :authenticate, if: :json_api_request?
  before_action :authenticate_user!, unless: :json_api_request?

  def index
    set_session_filters

    all_logs = current_user.lettings_logs + current_user.sales_logs 
    unpaginated_filtered_logs = filtered_logs(filtered_collection(all_logs, search_term))

    respond_to do |format|
      format.html do
        @pagy, @lettings_logs = pagy(unpaginated_filtered_logs)
        @searched = search_term.presence
        @total_count = all_logs.size
      end

      format.csv do
        send_data byte_order_mark + unpaginated_filtered_logs.to_csv(current_user), filename: "logs-#{Time.zone.now}.csv"
      end
    end
  end

private

  def create
    log = yield
    raise "Caller must pass a block that implements model creation" if log.blank?

    respond_to do |format|
      format.html do
        log.save!
        redirect_to post_create_redirect_url(log)
      end
      format.json do
        if log.save
          render json: log, status: :created
        else
          render json: { errors: log.errors.messages }, status: :unprocessable_entity
        end
      end
    end
  end

  def post_create_redirect_url
    raise "implement in sub class"
  end

  API_ACTIONS = %w[create show update destroy].freeze

  def json_api_request?
    API_ACTIONS.include?(request["action"]) && request.format.json?
  end

  def authenticate
    http_basic_authenticate_or_request_with name: ENV["API_USER"], password: ENV["API_KEY"]
  end

  def log_params
    if current_user && !current_user.support?
      org_params.merge(api_log_params)
    else
      api_log_params
    end
  end

  def api_log_params
    return {} unless params[:lettings_log] || params[:sales_log]

    permitted = permitted_log_params
    owning_id = permitted["owning_organisation_id"]
    permitted["owning_organisation"] = Organisation.find(owning_id) if owning_id
    permitted
  end

  def org_params
    {
      "owning_organisation_id" => current_user.organisation.id,
      "managing_organisation_id" => current_user.organisation.id,
      "created_by_id" => current_user.id,
    }
  end

  def search_term
    params["search"]
  end
end
