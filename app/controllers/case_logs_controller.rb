class CaseLogsController < ApplicationController
  skip_before_action :verify_authenticity_token, if: :json_create_request?
  before_action :authenticate, if: :json_create_request?

  def index
    @submitted_case_logs = CaseLog.where(status: 1)
    @in_progress_case_logs = CaseLog.where(status: 0)
  end

  def create
    case_log = CaseLog.create(create_params)
    respond_to do |format|
      format.html { redirect_to case_log }
      format.json do
        if case_log.persisted?
          render json: case_log, status: :created
        else
          render json: { errors: case_log.errors.full_messages }, status: :unprocessable_entity
        end
      end
    end
  end

  # We don't have a dedicated non-editable show view
  def show
    edit
  end

  def edit
    @form = use_form
    @case_log = CaseLog.find(params[:id])
    render :edit
  end

  def submit_form
    form = use_form
    @case_log = CaseLog.find(params[:id])
    previous_page = params[:case_log][:previous_page]
    questions_for_page = form.questions_for_page(previous_page)
    responses_for_page = question_responses(questions_for_page)
    @case_log.previous_page = previous_page
    if @case_log.update(responses_for_page)
      redirect_path = form.next_page_redirect_path(previous_page)
      redirect_to(send(redirect_path, @case_log))
    else
      page_info = form.all_pages[previous_page]
      render "form/page", locals: { form: form, page_key: previous_page, page_info: page_info }, status: :unprocessable_entity
    end
  end

  def check_answers
    form = use_form
    @case_log = CaseLog.find(params[:case_log_id])
    current_url = request.env["PATH_INFO"]
    subsection = current_url.split("/")[-2]
    render "form/check_answers", locals: { case_log: @case_log, subsection: subsection, form: form }
  end

  form = ENV["RAILS_ENV"] == "test" ? Form.new("test", "form") : Form.new(2021, 2022)
  form.all_pages.map do |page_key, page_info|
    define_method(page_key) do |_errors = {}|
      @case_log = CaseLog.find(params[:case_log_id])
      render "form/page", locals: { form: form, page_key: page_key, page_info: page_info }
    end
  end

private

  def question_responses(questions_for_page)
    questions_for_page.each_with_object({}) do |(question_key, question_info), result|
      question_params = params["case_log"][question_key]
      if question_info["type"] == "checkbox"
        question_info["answer_options"].keys.reject { |x| x.match(/divider/) }.each do |option|
          result[option] = question_params.include?(option)
        end
      else
        result[question_key] = question_params
      end
      result
    end
  end

  def json_create_request?
    (request["action"] == "create") && request.format.json?
  end

  def authenticate
    http_basic_authenticate_or_request_with name: ENV["API_USER"], password: ENV["API_KEY"]
  end

  def create_params
    return {} unless params[:case_log]

    params.require(:case_log).permit(CaseLog.editable_fields)
  end 
  
  def use_form
    ENV["RAILS_ENV"] == "test" ? Form.new("test", "form") : Form.new(2021, 2022)
  end
end
