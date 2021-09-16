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

  def next_question
    @case_log = CaseLog.find(params[:case_log_id])
    previous_question = params[:previous_question]
    previous_answer = params[previous_question]
    @case_log.update!(previous_question => previous_answer)
    next_question = Form::QUESTIONS[previous_question]
    redirect_to(send("case_log_#{next_question}_path", @case_log))
  end

  Form::QUESTIONS.each_key do |question|
    define_method(question) do
      @case_log = CaseLog.find(params[:case_log_id])
      render "form/questions/#{question}", locals: { case_log_id: @case_log.id }
    end
  end
end
