class FormController < ApplicationController
  before_action :authenticate_user!
  before_action :find_resource, only: %i[submit_form review]
  before_action :find_resource_by_named_id, except: %i[submit_form review]

  def submit_form
    if @lettings_log
      @page = @lettings_log.form.get_page(params[:lettings_log][:page])
      responses_for_page = responses_for_page(@page)
      mandatory_questions_with_no_response = mandatory_questions_with_no_response(responses_for_page)

      if mandatory_questions_with_no_response.empty? && @lettings_log.update(responses_for_page)
        session[:errors] = session[:fields] = nil
        redirect_to(successful_redirect_path)
      else
        redirect_path = "lettings_log_#{@page.id}_path"
        mandatory_questions_with_no_response.map do |question|
          @lettings_log.errors.add question.id.to_sym, question.unanswered_error_message
        end
        session[:errors] = @lettings_log.errors.to_json
        Rails.logger.info "User triggered validation(s) on: #{@lettings_log.errors.map(&:attribute).join(', ')}"
        redirect_to(send(redirect_path, @lettings_log))
      end
    else
      render_not_found
    end
  end

  def check_answers
    if @lettings_log
      current_url = request.env["PATH_INFO"]
      subsection = @lettings_log.form.get_subsection(current_url.split("/")[-2])
      render "form/check_answers", locals: { subsection:, current_user: }
    else
      render_not_found
    end
  end

  def review
    if @lettings_log
      render "form/review"
    else
      render_not_found
    end
  end

  FormHandler.instance.forms.each do |_key, form|
    form.pages.map do |page|
      define_method(page.id) do |_errors = {}|
        if @lettings_log
          restore_error_field_values
          @subsection = @lettings_log.form.subsection_for_page(page)
          @page = @lettings_log.form.get_page(page.id)
          if @page.routed_to?(@lettings_log, current_user)
            render "form/page"
          else
            redirect_to lettings_log_path(@lettings_log)
          end
        else
          render_not_found
        end
      end
    end
  end

private

  def restore_error_field_values
    if session["errors"]
      JSON(session["errors"]).each do |field, messages|
        messages.each { |message| @lettings_log.errors.add field.to_sym, message }
      end
    end
    if session["fields"]
      session["fields"].each do |field, value|
        unless @lettings_log.form.get_question(field, @lettings_log)&.type == "date"
          @lettings_log[field] = value
        end
      end
    end
  end

  def responses_for_page(page)
    page.questions.each_with_object({}) do |question, result|
      question_params = params["lettings_log"][question.id]
      if question.type == "date"
        day = params["lettings_log"]["#{question.id}(3i)"]
        month = params["lettings_log"]["#{question.id}(2i)"]
        year = params["lettings_log"]["#{question.id}(1i)"]
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
    @lettings_log = current_user.lettings_logs.find_by(id: params[:id])
  end

  def find_resource_by_named_id
    @lettings_log = current_user.lettings_logs.find_by(id: params[:lettings_log_id])
  end

  def is_referrer_check_answers?
    referrer = request.headers["HTTP_REFERER"].presence || ""
    referrer.present? && CGI.parse(referrer.split("?")[-1]).present? && CGI.parse(referrer.split("?")[-1])["referrer"][0] == "check_answers"
  end

  def successful_redirect_path
    if is_referrer_check_answers?
      page_ids = @lettings_log.form.subsection_for_page(@page).pages.map(&:id)
      page_index = page_ids.index(@page.id)
      next_page = @lettings_log.form.next_page(@page, @lettings_log, current_user)
      previous_page = @lettings_log.form.previous_page(page_ids, page_index, @lettings_log, current_user)
      if next_page.to_s.include?("value_check") || next_page == previous_page
        return "/logs/#{@lettings_log.id}/#{next_page.dasherize}?referrer=check_answers"
      else
        return send("lettings_log_#{@lettings_log.form.subsection_for_page(@page).id}_check_answers_path", @lettings_log)
      end
    end
    redirect_path = @lettings_log.form.next_page_redirect_path(@page, @lettings_log, current_user)
    send(redirect_path, @lettings_log)
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
    LettingsLog::OPTIONAL_FIELDS.exclude?(question.id) && required_questions.include?(question.id)
  end

  def required_questions
    @required_questions ||= begin
      log = @lettings_log
      log.assign_attributes(responses_for_page(@page))
      @page.subsection.applicable_questions(log).select { |q| q.enabled?(log) }.map(&:id)
    end
  end

  def question_missing_response?(responses_for_page, question)
    if %w[checkbox validation_override].include?(question.type)
      answered = question.answer_options.keys.reject { |x| x.match(/divider/) }.map do |option|
        session["fields"][option] = @lettings_log[option] = params["lettings_log"][question.id].include?(option) ? 1 : 0
        params["lettings_log"][question.id].exclude?(option)
      end
      answered.all?
    else
      session["fields"][question.id] = @lettings_log[question.id] = responses_for_page[question.id]
      responses_for_page[question.id].nil? || responses_for_page[question.id].blank?
    end
  end
end
