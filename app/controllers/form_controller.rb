class FormController < ApplicationController
  before_action :authenticate_user!
  before_action :find_resource, only: %i[review]
  before_action :find_resource_by_named_id, except: %i[review]
  before_action :check_collection_period, only: %i[submit_form show_page]

  def submit_form
    if @log
      @page = form.get_page(params[@log.model_name.param_key][:page])
      responses_for_page = responses_for_page(@page)
      mandatory_questions_with_no_response = mandatory_questions_with_no_response(responses_for_page)

      if mandatory_questions_with_no_response.empty? && @log.update(responses_for_page.merge(updated_by: current_user))
        flash[:notice] = "You have successfully updated #{@page.questions.map(&:check_answer_label).reject { |label| label.to_s.empty? }.first&.downcase}" if previous_interruption_screen_page_id.present?
        redirect_to(successful_redirect_path)
      else
        mandatory_questions_with_no_response.map do |question|
          @log.errors.add question.id.to_sym, question.unanswered_error_message
        end
        Rails.logger.info "User triggered validation(s) on: #{@log.errors.map(&:attribute).join(', ')}"
        @subsection = form.subsection_for_page(@page)
        restore_error_field_values(@page&.questions)
        render "form/page"
      end
    else
      render_not_found
    end
  end

  def check_answers
    if @log
      current_url = request.env["PATH_INFO"]
      subsection = form.get_subsection(current_url.split("/")[-2])
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
    if request.params["referrer"] == "interruption_screen" && request.headers["HTTP_REFERER"].present?
      @interruption_page_id = URI.parse(request.headers["HTTP_REFERER"]).path.split("/").last.underscore
      @interruption_page_referrer_type = from_referrer_query("referrer")
    end

    if @log
      page_id = request.path.split("/")[-1].underscore
      @page = form.get_page(page_id)
      @subsection = form.subsection_for_page(@page)
      if @page.routed_to?(@log, current_user) || is_referrer_type?("interruption_screen")
        render "form/page"
      else
        redirect_to @log.lettings? ? lettings_log_path(@log) : sales_log_path(@log)
      end
    else
      render_not_found
    end
  end

private

  def restore_error_field_values(questions)
    return unless questions

    questions.each do |question|
      if question&.type == "date" && @log.attributes.key?(question.id)
        @log[question.id] = @log.send("#{question.id}_was")
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
        question.answer_keys_without_dividers.each do |option|
          result[option] = question_params.include?(option) ? 1 : 0
        end
      else
        result[question.id] = question_params
      end

      if question.id == "owning_organisation_id"
        owning_organisation = result["owning_organisation_id"].present? ? Organisation.find(result["owning_organisation_id"]) : nil
        if current_user.support? && @log.managing_organisation.blank? && owning_organisation&.managing_agents&.empty?
          result["managing_organisation_id"] = owning_organisation.id
        elsif owning_organisation&.absorbing_organisation == current_user.organisation
          result["managing_organisation_id"] = owning_organisation.id
        elsif @log.managing_organisation&.absorbing_organisation == current_user.organisation && owning_organisation == current_user.organisation
          result["managing_organisation_id"] = owning_organisation.id
        end
      end

      result
    end
  end

  def find_resource
    @log = if params.key?("sales_log")
             current_user.sales_logs.visible.find_by(id: params[:id])
           else
             current_user.lettings_logs.visible.find_by(id: params[:id])
           end
  end

  def find_resource_by_named_id
    @log = if params[:sales_log_id].present?
             current_user.sales_logs.visible.find_by(id: params[:sales_log_id])
           else
             current_user.lettings_logs.visible.find_by(id: params[:lettings_log_id])
           end
  end

  def is_referrer_type?(referrer_type)
    from_referrer_query("referrer") == referrer_type
  end

  def from_referrer_query(query_param)
    referrer = request.headers["HTTP_REFERER"]
    return unless referrer

    query_params = URI.parse(referrer).query
    return unless query_params

    parsed_params = CGI.parse(query_params)
    parsed_params[query_param]&.first
  end

  def original_duplicate_log_id_from_query
    query_params = URI.parse(request.url).query

    return unless query_params

    parsed_params = CGI.parse(query_params)
    parsed_params["original_log_id"]&.first
  end

  def previous_interruption_screen_page_id
    params[@log.model_name.param_key]["interruption_page_id"]
  end

  def previous_interruption_screen_referrer
    params[@log.model_name.param_key]["interruption_page_referrer_type"].presence
  end

  def successful_redirect_path
    if FeatureToggle.deduplication_flow_enabled?
      if is_referrer_type?("duplicate_logs") || is_referrer_type?("duplicate_logs_banner")
        return correcting_duplicate_logs_redirect_path
      end

      dynamic_duplicates = @log.lettings? ? current_user.lettings_logs.duplicate_logs(@log) : current_user.sales_logs.duplicate_logs(@log)
      if dynamic_duplicates.count.positive?
        saved_duplicates = @log.duplicates
        unless saved_duplicates == dynamic_duplicates
          @log.update!(duplicate_set_id: new_duplicate_set_id) if @log.duplicate_set_id.blank?
          dynamic_duplicates.each do |duplicate|
            duplicate.update!(duplicate_set_id: @log.duplicate_set_id) if duplicate.duplicate_set_id != @log.duplicate_set_id
          end
        end
        return send("#{@log.class.name.underscore}_duplicate_logs_path", @log, original_log_id: @log.id)
      end
    end

    if is_referrer_type?("check_answers")
      next_page_id = form.next_page_id(@page, @log, current_user)
      next_page = form.get_page(next_page_id)
      previous_page = form.previous_page_id(@page, @log, current_user)

      if next_page&.interruption_screen? || next_page_id == previous_page || CONFIRMATION_PAGE_IDS.include?(next_page_id)
        return send("#{@log.class.name.underscore}_#{next_page_id}_path", @log, { referrer: "check_answers" })
      else
        return send("#{@log.model_name.param_key}_#{form.subsection_for_page(@page).id}_check_answers_path", @log)
      end
    end
    if previous_interruption_screen_page_id.present?
      return send("#{@log.class.name.underscore}_#{previous_interruption_screen_page_id}_path", @log, { referrer: previous_interruption_screen_referrer, original_log_id: original_duplicate_log_id_from_query }.compact)
    end

    redirect_path = form.next_page_redirect_path(@page, @log, current_user)
    send(redirect_path, @log)
  end

  def form
    @log&.form
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
    @log.optional_fields.exclude?(question.id) && required_questions.include?(question.id)
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
      answered = question.answer_keys_without_dividers.map do |option|
        session["fields"][option] = @log[option] = params[@log.model_name.param_key][question.id].include?(option) ? 1 : 0
        params[@log.model_name.param_key][question.id].exclude?(option)
      end
      answered.all?
    else
      session["fields"][question.id] = @log[question.id] = responses_for_page[question.id]
      responses_for_page[question.id].nil? || responses_for_page[question.id].blank?
    end
  end

  def check_collection_period
    return unless @log

    redirect_to lettings_log_path(@log) unless @log.collection_period_open_for_editing?
  end

  CONFIRMATION_PAGE_IDS = %w[uprn_confirmation].freeze

  def correcting_duplicate_logs_redirect_path
    class_name = @log.class.name.underscore

    original_log = current_user.send(class_name.pluralize).find_by(id: from_referrer_query("original_log_id"))

    if original_log.present? && current_user.send(class_name.pluralize).duplicate_logs(original_log).count.positive?
      unless current_user.send(class_name.pluralize).duplicate_logs(@log).count.positive?
        remove_fixed_duplicate_set_ids(@log)
        flash[:notice] = deduplication_success_banner
      end
      send("#{class_name}_duplicate_logs_path", original_log, original_log_id: original_log.id, referrer: params[:referrer], organisation_id: params[:organisation_id])
    else
      remove_fixed_duplicate_set_ids(original_log)
      flash[:notice] = deduplication_success_banner
      send("#{class_name}_duplicate_logs_path", "#{class_name}_id".to_sym => from_referrer_query("first_remaining_duplicate_id"), original_log_id: from_referrer_query("original_log_id"), referrer: params[:referrer], organisation_id: params[:organisation_id])
    end
  end

  def deduplication_success_banner
    deduplicated_log_link = "<a class=\"govuk-notification-banner__link govuk-!-font-weight-bold\" href=\"#{send("#{@log.class.name.underscore}_path", @log)}\">Log #{@log.id}</a>"
    changed_labels = {
      property_postcode: "postcode",
      lead_tenant_age: "lead tenant’s age",
      rent_4_weekly: "household rent and charges",
      rent_bi_weekly: "household rent and charges",
      rent_monthly: "household rent and charges",
      rent_or_other_charges: "household rent and charges",
      address: "postcode",
    }
    changed_question_label = changed_labels[@page.id.to_sym] || (@page.questions.first.check_answer_label.to_s.presence || @page.questions.first.header.to_s).downcase

    I18n.t("notification.duplicate_logs.deduplication_success_banner", log_link: deduplicated_log_link, changed_question_label:).html_safe
  end

  def remove_fixed_duplicate_set_ids(log)
    duplicate_set_id = log.duplicate_set_id
    return unless duplicate_set_id

    log.update!(duplicate_set_id: nil)
    LettingsLog.find_by(duplicate_set_id:)&.update!(duplicate_set_id: nil) if log.lettings? && LettingsLog.where(duplicate_set_id:).count == 1
    SalesLog.find_by(duplicate_set_id:)&.update!(duplicate_set_id: nil) if log.sales? && SalesLog.where(duplicate_set_id:).count == 1
  end

  def new_duplicate_set_id
    loop do
      duplicate_set_id = SecureRandom.random_number(1_000_000)
      return duplicate_set_id unless LettingsLog.exists?(duplicate_set_id:)
    end
  end
end
