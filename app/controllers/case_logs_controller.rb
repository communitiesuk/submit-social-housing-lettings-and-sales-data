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

  def update_checkbox_responses(case_log, questions_for_page)
    result = {}
    case_log.each do |question, answer|
      if question == "previous_page"
        result[question] = answer
      elsif questions_for_page[question]["type"] == "checkbox"
        questions_for_page[question]["answer_options"].keys.reject { |x| x.match(/divider/) }.each do |option|
          result[option] = case_log[question].include?(option) ? true : false
        end
      else
        result[question] = answer
      end
    end
    result
  end

  def submit_form
    form = Form.new(2021, 2022)
    @case_log = CaseLog.find(params[:id])
    previous_page = params[:case_log][:previous_page]
    questions_for_page = form.questions_for_page(previous_page)
    checkbox_questions_for_page = form.checkbox_questions_for_page(previous_page)
    all_question_keys = questions_for_page.keys + checkbox_questions_for_page
    params[:case_log] = update_checkbox_responses(params[:case_log], questions_for_page)

    answers_for_page = page_params(all_question_keys).select { |k, _v| all_question_keys.include?(k) }
    if @case_log.update(answers_for_page)
      redirect_path = form.next_page_redirect_path(previous_page)
      redirect_to(send(redirect_path, @case_log))
    else
      page_info = form.all_pages[previous_page]
      render "form/page", locals: { form: form, page_key: previous_page, page_info: page_info }, status: :unprocessable_entity
    end
  end

  def check_answers
    @case_log = CaseLog.find(params[:case_log_id])
    current_url = request.env["PATH_INFO"]
    subsection = current_url.split("/")[-2]
    render "form/check_answers", locals: { case_log: @case_log, subsection: subsection }
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
