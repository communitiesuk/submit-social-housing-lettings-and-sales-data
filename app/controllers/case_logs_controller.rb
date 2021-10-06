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
    render :edit
  end

  def next_page
    form = Form.new(2021, 2022)
    @case_log = CaseLog.find(params[:id])
    previous_page = params[:case_log][:previous_page]
    questions_for_page = form.questions_for_page(previous_page).keys
    answers_for_page = page_params(questions_for_page).select { |k, _v| questions_for_page.include?(k) }
    begin
      @case_log.update!(answers_for_page)
      next_page = form.next_page(previous_page)
      redirect_path = if next_page == :check_answers
                        subsection = form.subsection_for_page(previous_page)
                        "case_log_#{subsection}_check_answers_path"
                      else
                        "case_log_#{next_page}_path"
                      end

      redirect_to(send(redirect_path, @case_log))
    rescue ActiveRecord::RecordInvalid
      page_info = form.all_pages[previous_page]
      render "form/page", locals: { form: form, page_key: previous_page, page_info: page_info }, status: :unprocessable_entity
    end
  end

  def check_answers
    @case_log = CaseLog.find(params[:case_log_id])
    form = Form.new(2021, 2022)
    current_url = request.env["PATH_INFO"]
    subsection = current_url.split("/")[-2]
    subsection_pages = form.pages_for_subsection(subsection)
    render "form/check_answers", locals: { case_log: @case_log, subsection_pages: subsection_pages, subsection: subsection.humanize(capitalize: false) }
  end

  form = Form.new(2021, 2022)
  form.all_pages.map do |page_key, page_info|
    define_method(page_key) do
      @case_log = CaseLog.find(params[:case_log_id])
      render "form/page", locals: { form: form, page_key: page_key, page_info: page_info }
    end
  end

private

  def page_params(questions_for_page)
    params.require(:case_log).permit(questions_for_page)
  end
end
