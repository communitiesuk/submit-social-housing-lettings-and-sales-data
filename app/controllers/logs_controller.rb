class LogsController < ApplicationController
  include Pagy::Backend
  include Modules::LogsFilter
  include Modules::SearchFilter

  skip_before_action :verify_authenticity_token, if: :json_api_request?
  before_action :authenticate, if: :json_api_request?
  before_action :authenticate_user!, unless: :json_api_request?

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
    owning_organisation_id = current_user.organisation.holds_own_stock? ? current_user.organisation.id : nil
    {
      "owning_organisation_id" => owning_organisation_id,
      "created_by_id" => current_user.id,
    }
  end

  def search_term
    params["search"]
  end
end
