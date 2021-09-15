class CaseLogsController < ApplicationController
  def index
    @submitted_case_logs = CaseLog.where(status: 1)
    @in_progress_case_logs = CaseLog.where(status: 0)
  end

  # We don't have a dedicated non-editable show view
  def show
    @case_log = CaseLog.find(params[:id])
    render :edit
  end

  def edit
    @case_log = CaseLog.find(params[:id])
  end

  # def update
  #   @case_log = CaseLog.find(params[:id])
  #   @case_log.update!(tenant_code: params[:case_log][:tenant_code]) if params[:case_log]
  #   render_next_question(@case_log)
  # end
end
