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
    edit
  end

  def edit
    @form = Form.new(2021, 2022)
    @case_log = CaseLog.find(params[:id])
    render :edit, locals: { form: @form }
  end

  def next_page
    form = Form.new(2021, 2022)
    @case_log = CaseLog.find(params[:case_log_id])
    previous_page = params[:previous_page]
    questions_for_page = form.questions_for_page(previous_page).keys
    answers_for_page = page_params(questions_for_page).select { |k, _v| questions_for_page.include?(k) }
    @case_log.update!(answers_for_page)
    next_page = form.next_page(previous_page)
    redirect_to(send("case_log_#{next_page}_path", @case_log))
  end

  def page_params(questions_for_page)
    params.permit(questions_for_page)
  end

  form = Form.new(2021, 2022)
  form.all_pages.keys.map do |page|
    define_method(page) do
      @case_log = CaseLog.find(params[:case_log_id])
      render "form/pages/#{page}", locals: { case_log_id: @case_log.id, form: form }
    end
  end
end
