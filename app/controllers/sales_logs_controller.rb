class SalesLogsController < LogsController
  before_action :session_filters, if: :current_user, only: %i[index email_csv download_csv]
  before_action :set_session_filters, if: :current_user, only: %i[index email_csv download_csv]
  before_action :authenticate_scope!, only: %i[download_csv email_csv]

  def create
    super { SalesLog.new(log_params) }
  end

  def index
    respond_to do |format|
      format.html do
        all_logs = current_user.sales_logs.visible
        unpaginated_filtered_logs = filtered_logs(all_logs, search_term, @session_filters)

        @search_term = search_term
        @pagy, @logs = pagy(unpaginated_filtered_logs)
        @searched = search_term.presence
        @total_count = all_logs.size
        render "logs/index"
      end
    end
  end

  def show
    respond_to do |format|
      format.html { edit }
    end
  end

  def edit
    @log = current_user.sales_logs.visible.find_by(id: params[:id])
    if @log
      render "logs/edit", locals: { current_user: }
    else
      render_not_found
    end
  end

  def download_csv
    unpaginated_filtered_logs = filtered_logs(current_user.sales_logs, search_term, @session_filters)

    render "download_csv", locals: { search_term:, count: unpaginated_filtered_logs.size, post_path: email_csv_sales_logs_path, codes_only: codes_only_export? }
  end

  def email_csv
    all_orgs = params["organisation_select"] == "all" # what's this for? params['organisation_select'] appears to always be nil
    EmailCsvJob.perform_later(current_user, search_term, @session_filters, all_orgs, nil, codes_only_export?, "sales")
    redirect_to csv_confirmation_sales_logs_path
  end

  def csv_confirmation; end

  def post_create_redirect_url(log)
    sales_log_url(log)
  end

  def permitted_log_params
    params.require(:sales_log).permit(SalesLog.editable_fields)
  end

private

  def authenticate_scope!
    head :unauthorized and return if codes_only_export? && !current_user.support?
  end
end
