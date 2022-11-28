class LettingsLogsController < LogsController
  before_action :find_resource, except: %i[create index edit]
  before_action :session_filters, if: :current_user
  before_action :set_session_filters, if: :current_user

  def index
    respond_to do |format|
      format.html do
        all_logs = current_user.lettings_logs
        unpaginated_filtered_logs = filtered_logs(all_logs, search_term, @session_filters)

        @search_term = search_term
        @pagy, @logs = pagy(unpaginated_filtered_logs)
        @searched = search_term.presence
        @total_count = all_logs.size
        render "logs/index"
      end
    end
  end

  def create
    super { LettingsLog.new(log_params) }
  end

  def update
    if @log
      if @log.update(api_log_params)
        render json: @log, status: :ok
      else
        render json: { errors: @log.errors.messages }, status: :unprocessable_entity
      end
    else
      render_not_found_json("Log", params[:id])
    end
  end

  def show
    respond_to do |format|
      # We don't have a dedicated non-editable show view
      mark_logs_resolved
      format.html { edit }
      format.json do
        if @log
          render json: @log, status: :ok
        else
          render_not_found_json("Log", params[:id])
        end
      end
    end
  end

  def edit
    @log = current_user.lettings_logs.find_by(id: params[:id])
    if @log
      if @log.unresolved
        redirect_to(send("lettings_log_#{@log.form.get_question('startdate', @log).page.id}_path", @log))
      else
        render("logs/edit", locals: { current_user: })
      end
    else
      render_not_found
    end
  end

  def destroy
    if @log
      if @log.delete
        head :no_content
      else
        render json: { errors: @log.errors.messages }, status: :unprocessable_entity
      end
    else
      render_not_found_json("Log", params[:id])
    end
  end

  def download_csv
    unpaginated_filtered_logs = filtered_logs(current_user.lettings_logs, search_term, @session_filters)

    render "download_csv", locals: { search_term:, count: unpaginated_filtered_logs.size, post_path: email_csv_lettings_logs_path }
  end

  def email_csv
    all_orgs = params["organisation_select"] == "all"
    EmailCsvJob.perform_later(current_user, search_term, @session_filters, all_orgs)
    redirect_to csv_confirmation_lettings_logs_path
  end

  def csv_confirmation; end

  def update_logs
    respond_to do |format|
      format.html do
        impacted_logs = current_user.lettings_logs.where(unresolved: true, created_by: current_user)

        @pagy, @logs = pagy(impacted_logs)
        @total_count = impacted_logs.size
        render "logs/update_logs"
      end
    end
  end

private

  def permitted_log_params
    params.require(:lettings_log).permit(LettingsLog.editable_fields)
  end

  def find_resource
    @log = LettingsLog.find_by(id: params[:id])
  end

  def post_create_redirect_url(log)
    lettings_log_url(log)
  end

  def mark_logs_resolved
    if @log&.unresolved == true && @log.location.present? && @log.scheme.present? && @log.update(unresolved: false)
      flash[:notice] = "This log is now complete"
    end
  end
end
