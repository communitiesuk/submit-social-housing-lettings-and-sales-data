class CaseLogsController < ApplicationController
  def index
    @submitted_case_logs = CaseLog.where(status: 1)
    @in_progress_case_logs = CaseLog.where(status: 0)
  end

  def create
    @case_log = CaseLog.create!
    redirect_to @case_log
  end

  # We don't have a dedicated non-editable show view
  def show
    @case_log = CaseLog.find(params[:id])
    render :edit
  end

  def edit
    @case_log = CaseLog.find(params[:id])
  end

  FIRST_QUESTION_FOR_SUBSECTION = {
    "Household characteristics" => "form/questions/household/tenant_code",
  }.freeze

  NEXT_QUESTION = {
    "tenant_code" => "form/questions/household/tenant_age",
    "tenant_age" => "form/questions/household/tenant_gender",
    "tenant_gender" => "form/questions/household/tenant_ethnic_group",
    "tenant_ethnic_group" => "form/questions/household/tenant_nationality",
  }.freeze

  def next_question
    subsection = params[:subsection]
    @case_log = CaseLog.find(params[:case_log_id])
    result = if subsection
               FIRST_QUESTION_FOR_SUBSECTION[subsection]
             else
               previous_question = params[:previous_question]
               answer = params[previous_question]
               @case_log.update!(previous_question => answer)
               NEXT_QUESTION[previous_question]
             end
    render result, locals: { case_log_id: @case_log.id }
  end
end
