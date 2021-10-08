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

  def submit_form
    form = Form.new(2021, 2022)
    @case_log = CaseLog.find(params[:id])
    previous_page = params[:case_log][:previous_page]
    questions_for_page = form.questions_for_page(previous_page)
    checked_answers = get_checked_answers(params[:case_log], questions_for_page)

    answers_for_page = page_params(questions_for_page.keys).select { |k, _v| questions_for_page.key?(k) }
    if @case_log.update(checked_answers) && @case_log.update(answers_for_page)
      redirect_path = form.next_page_redirect_path(previous_page)
      redirect_to(send(redirect_path, @case_log))
    else
      page_info = form.all_pages[previous_page]
      render "form/page", locals: { form: form, page_key: previous_page, page_info: page_info }, status: :unprocessable_entity
    end
  end

  def get_checked_answers(case_log_params, questions_for_page)
    checked_questions = {}
    checkbox_questions = questions_for_page.select { |_title, question| question["type"] == "checkbox" }
    checkbox_questions.each do |title, question|
      valid_answer_options = question["answer_options"].reject { |key, _value| key.match?(/divider/) }
      valid_answer_options.each do |value, _label|
        checked_questions[value] = case_log_params[title].include?(value) ? true : false
      end
    end
    checked_questions
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
