class SalesLogsController < LogsController
  before_action :session_filters, if: :current_user
  before_action :set_session_filters, if: :current_user

  def create
    super { SalesLog.new(log_params) }
  end

  def index
    respond_to do |format|
      format.html do
        all_logs = current_user.sales_logs
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
    @log = current_user.sales_logs.find_by(id: params[:id])
    if @log
      render "logs/edit", locals: { current_user: }
    else
      render_not_found
    end
  end

  def post_create_redirect_url(log)
    sales_log_url(log)
  end

  def permitted_log_params
    params.require(:sales_log).permit(SalesLog.editable_fields)
  end
end
