class SalesLogsController < LogsController
  def create
    super { SalesLog.new(log_params) }
  end

  def show
    respond_to do |format|
      format.html { "logs/edit" }
    end
  end

  def edit
    @sales_log = current_user.sales_logs.find_by(id: params[:id])
    if @sales_log
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
