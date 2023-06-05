class SalesLogsController < LogsController
  rescue_from ActiveRecord::RecordNotFound, with: :render_not_found

  before_action :session_filters, if: :current_user, only: %i[index email_csv download_csv]
  before_action -> { filter_manager.serialize_filters_to_session }, if: :current_user, only: %i[index email_csv download_csv]
  before_action :authenticate_scope!, only: %i[download_csv email_csv]

  before_action :extract_bulk_upload_from_session_filters, only: [:index]
  before_action :redirect_if_bulk_upload_resolved, only: [:index]

  def create
    super { SalesLog.new(log_params) }
  end

  def index
    respond_to do |format|
      format.html do
        all_logs = current_user.sales_logs.visible
        unpaginated_filtered_logs = filter_manager.filtered_logs(all_logs, search_term, session_filters)

        @search_term = search_term
        @pagy, @logs = pagy(unpaginated_filtered_logs)
        @searched = search_term.presence
        @total_count = all_logs.size
        @filter_type = "sales_logs"
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
    @log = current_user.sales_logs.visible.find(params[:id])
    render "logs/edit", locals: { current_user: }
  end

  def destroy
    @log = SalesLog.visible.find(params[:id])

    authorize @log

    @log.discard!

    redirect_to sales_logs_path, notice: "Log #{@log.id} has been deleted"
  end

  def delete_confirmation
    @log = SalesLog.visible.find(params[:sales_log_id])

    authorize @log, :destroy?

    render "logs/delete_confirmation"
  end

  def download_csv
    unpaginated_filtered_logs = filter_manager.filtered_logs(current_user.sales_logs, search_term, session_filters)

    render "download_csv", locals: { search_term:, count: unpaginated_filtered_logs.size, post_path: email_csv_sales_logs_path, codes_only: codes_only_export? }
  end

  def email_csv
    all_orgs = params["organisation_select"] == "all"
    EmailCsvJob.perform_later(current_user, search_term, session_filters, all_orgs, nil, codes_only_export?, "sales")
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

  def session_filters
    filter_manager.session_filters
  end

  def filter_manager
    FilterManager.new(current_user:, session:, params:, filter_type: "sales_logs")
  end

  def extract_bulk_upload_from_session_filters
    filter_manager = FilterManager.new(current_user:, session:, params:, filter_type: "lettings_logs")
    @bulk_upload = filter_manager.bulk_upload
  end

  def redirect_if_bulk_upload_resolved
    if @bulk_upload&.sales? && @bulk_upload.sales_logs.in_progress.count.zero?
      redirect_to resume_bulk_upload_sales_result_path(@bulk_upload)
    end
  end

  def authenticate_scope!
    head :unauthorized and return if codes_only_export? && !current_user.support?
  end
end
