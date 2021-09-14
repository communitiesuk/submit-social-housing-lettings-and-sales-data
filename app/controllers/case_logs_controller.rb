class CaseLogsController < ApplicationController
  def index
    @submitted_case_logs = CaseLog.where(status: 1)
    @in_progress_case_logs = CaseLog.where(status: 0)
  end

  def show
    @case_log = CaseLog.find(params[:id])
  end

  def edit
    @case_log = CaseLog.find(params[:id])
    render "case_logs/household/tenant_code"
  end

  def update
    @case_log = CaseLog.find(params[:id])
    @case_log.update!(tenant_code: params[:case_log][:tenant_code]) if params[:case_log]
    render_next_question(@case_log)
  end

private

  def render_next_question(_case_log)
    previous = params[:case_log].keys.first
    next_question = {
      "tenant_code" => "case_logs/household/tenant_age",
      "tenant_age" => "case_logs/household/tenant_gender",
    }[previous]
    render next_question
  end
end
