class FormController < ApplicationController
  before_action :authenticate_user!
  before_action :find_resource, only: %i[submit_form review]
  before_action :find_resource_by_named_id, except: %i[submit_form review show_new_page]
  before_action :create_new_resource, only: %i[show_new_page]

  def submit_form
    if @log
      @page = @log.form.get_page(params[@log.model_name.param_key][:page])
      responses_for_page = responses_for_page(@page)
      mandatory_questions_with_no_response = mandatory_questions_with_no_response(responses_for_page)

      if mandatory_questions_with_no_response.empty? && @log.update(responses_for_page)
        session[:errors] = session[:fields] = nil
        redirect_to(successful_redirect_path)
      else
        redirect_path = @log.status == "not_started" ? "#{@log.model_name.param_key}s_new_#{@page.id}_path" : "#{@log.model_name.param_key}_#{@page.id}_path"
        mandatory_questions_with_no_response.map do |question|
          @log.errors.add question.id.to_sym, question.unanswered_error_message
        end
        session[:errors] = @log.errors.to_json
        Rails.logger.info "User triggered validation(s) on: #{@log.errors.map(&:attribute).join(', ')}"
        redirect_to(send(redirect_path, @log))
      end
    else
      render_not_found
    end
  end

  def check_answers
    if @log
      current_url = request.env["PATH_INFO"]
      subsection = @log.form.get_subsection(current_url.split("/")[-2])
      render "form/check_answers", locals: { subsection:, current_user: }
    else
      render_not_found
    end
  end

  def review
    if @log
      render "form/review"
    else
      render_not_found
    end
  end

  def show_page
    if @log
      restore_error_field_values
      page_id = request.path.split("/")[-1].underscore
      @page = @log.form.get_page(page_id)
      @subsection = @log.form.subsection_for_page(@page)
      if @page.routed_to?(@log, current_user)
        render "form/page"
      else
        redirect_to lettings_log_path(@log)
      end
    else
      render_not_found
    end
  end

  def show_new_page
    page_id = request.path.split("/")[-1].underscore
    if @log
      restore_error_field_values
      page_id = request.path.split("/")[-1].underscore
      @page = @log.form.get_page(page_id)
      @subsection = @log.form.subsection_for_page(@page)
      if @page.routed_to?(@log, current_user)
        render "form/page"
      else
        redirect_to lettings_log_path(@log)
      end
    else
      render_not_found
    end
  end

private

  def save_new_log(page_id)
    if current_user.support?
      @log.save! unless page_id.eql?("organisation") && @log.id.nil?
    else
      @log.save! unless page_id.eql?("needs_type") && @log.id.nil?
    end
  end

  def restore_error_field_values
    if session["errors"]
      JSON(session["errors"]).each do |field, messages|
        messages.each { |message| @log.errors.add field.to_sym, message }
      end
    end
    if session["fields"]
      session["fields"].each do |field, value|
        if @log.form.get_question(field, @log)&.type != "date" && @log.respond_to?(field)
          @log[field] = value
        end
      end
    end
  end

  def responses_for_page(page)
    page.questions.each_with_object({}) do |question, result|
      question_params = params[@log.model_name.param_key][question.id]
      if question.type == "date"
        day = params[@log.model_name.param_key]["#{question.id}(3i)"]
        month = params[@log.model_name.param_key]["#{question.id}(2i)"]
        year = params[@log.model_name.param_key]["#{question.id}(1i)"]
        next unless [day, month, year].any?(&:present?)

        result[question.id] = if Date.valid_date?(year.to_i, month.to_i, day.to_i) && year.to_i.between?(2000, 2200)
                                Date.new(year.to_i, month.to_i, day.to_i)
                              else
                                Date.new(0, 1, 1)
                              end
      end
      next unless question_params

      if %w[checkbox validation_override].include?(question.type)
        question.answer_options.keys.reject { |x| x.match(/divider/) }.each do |option|
          result[option] = question_params.include?(option) ? 1 : 0
        end
      else
        result[question.id] = question_params
      end
      result
    end
  end

  def find_resource
    @log = if params.key?("sales_log")
             if new_log_request? || new_log_request_referrer?
               SalesLog.new(owning_organisation: current_user.support? ? nil : current_user.organisation)
             else
               current_user.sales_logs.find_by(id: params[:id])
             end
           elsif new_log_request? || new_log_request_referrer?
             LettingsLog.new(owning_organisation: current_user.support? ? nil : current_user.organisation)
           else
             current_user.lettings_logs.find_by(id: params[:id])
           end
  end

  def find_resource_by_named_id
    @log = if params[:sales_log_id].present?
             current_user.sales_logs.find_by(id: params[:sales_log_id])
           elsif new_log_request?
             if request.path.include?("sales-logs")
               SalesLog.new
             else
               LettingsLog.new
             end
           else
             current_user.lettings_logs.find_by(id: params[:lettings_log_id])
           end
  end

  def create_new_resource
    @log = if request.path.include?("sales-logs")
      SalesLog.new
    else
      LettingsLog.new
    end
  end

  def new_log_request?
    request.path.split("/").include?("new")
  end

  def new_log_request_referrer?
    request.referer.split("/").include?("new")
  end

  def is_referrer_check_answers?
    referrer = request.headers["HTTP_REFERER"].presence || ""
    referrer.present? && CGI.parse(referrer.split("?")[-1]).present? && CGI.parse(referrer.split("?")[-1])["referrer"][0] == "check_answers"
  end

  def successful_redirect_path
    if is_referrer_check_answers?
      page_ids = @log.form.subsection_for_page(@page).pages.map(&:id)
      page_index = page_ids.index(@page.id)
      next_page = @log.form.next_page(@page, @log, current_user)
      previous_page = @log.form.previous_page(page_ids, page_index, @log, current_user)
      if next_page.to_s.include?("value_check") || next_page == previous_page
        return send("#{@log.class.name.underscore}_#{next_page}_path", @log, { referrer: "check_answers" })
      else
        return send("#{@log.model_name.param_key}_#{@log.form.subsection_for_page(@page).id}_check_answers_path", @log)
      end
    end
    redirect_path = @log.form.next_page_redirect_path(@page, @log, current_user)
    send(redirect_path, @log)
  end

  def mandatory_questions_with_no_response(responses_for_page)
    session["fields"] = {}
    calc_questions = @page.questions.map(&:result_field)
    @page.questions.select do |question|
      next if calc_questions.include?(question.id)

      question_is_required?(question) && question_missing_response?(responses_for_page, question)
    end
  end

  def question_is_required?(question)
    @log.class::OPTIONAL_FIELDS.exclude?(question.id) && required_questions.include?(question.id)
  end

  def required_questions
    @required_questions ||= begin
      log = @log
      log.assign_attributes(responses_for_page(@page))
      @page.subsection.applicable_questions(log).select { |q| q.enabled?(log) }.map(&:id)
    end
  end

  def question_missing_response?(responses_for_page, question)
    if %w[checkbox validation_override].include?(question.type)
      answered = question.answer_options.keys.reject { |x| x.match(/divider/) }.map do |option|
        session["fields"][option] = @log[option] = params[@log.model_name.param_key][question.id].include?(option) ? 1 : 0
        params[@log.model_name.param_key][question.id].exclude?(option)
      end
      answered.all?
    else
      session["fields"][question.id] = @log[question.id] = responses_for_page[question.id]
      responses_for_page[question.id].nil? || responses_for_page[question.id].blank?
    end
  end
end
