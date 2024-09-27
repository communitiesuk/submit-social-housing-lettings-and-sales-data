class LettingsLogsController < LogsController
  include DuplicateLogsHelper

  rescue_from ActiveRecord::RecordNotFound, with: :render_not_found

  before_action :find_resource, only: %i[update show]

  before_action :session_filters, if: :current_user, only: %i[index email_csv download_csv bulk_uploads]
  before_action -> { filter_manager.serialize_filters_to_session }, if: :current_user, only: %i[index email_csv download_csv bulk_uploads]
  before_action :authenticate_scope!, only: %i[download_csv email_csv]

  before_action :extract_bulk_upload_from_session_filters, only: [:index]
  before_action :redirect_if_bulk_upload_resolved, only: [:index]

  def index
    all_logs = current_user.lettings_logs.visible.filter_by_years_or_nil(FormHandler.instance.years_of_available_lettings_forms)
    unpaginated_filtered_logs = filter_manager.filtered_logs(all_logs, search_term, session_filters)

    @delete_logs_path = delete_logs_lettings_logs_path(search: search_term)
    @pagy, @logs = pagy(unpaginated_filtered_logs)
    @searched = search_term.presence
    @total_count = all_logs.size
    @unresolved_count = all_logs.unresolved.assigned_to(current_user).count
    @filter_type = "lettings_logs"
    @duplicate_sets_count = FeatureToggle.duplicate_summary_enabled? && !current_user.support? ? duplicate_sets_count(current_user, current_user.organisation) : 0
    render "logs/index"
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
      resolve_logs!
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
    @log = current_user.lettings_logs.find(params[:id])

    if @log.unresolved
      redirect_to(send(@log.form.unresolved_log_path, @log))
    elsif @log.collection_closed_for_editing?
      redirect_to review_lettings_log_path(@log)
    else
      render("logs/edit", locals: { current_user: })
    end
  end

  def destroy
    @log = LettingsLog.visible.find(params[:id])

    authorize @log

    @log.discard!

    redirect_to lettings_logs_path, notice: "Log #{@log.id} has been deleted."
  end

  def delete_confirmation
    @log = LettingsLog.visible.find(params[:lettings_log_id])

    authorize @log, :destroy?

    render "logs/delete_confirmation"
  end

  def download_csv
    redirect_to filters_years_lettings_logs_path(search: search_term, codes_only: codes_only_export?) and return if session_filters["years"].blank? || session_filters["years"].count != 1

    unpaginated_filtered_logs = filter_manager.filtered_logs(current_user.lettings_logs.visible, search_term, session_filters)

    render "download_csv", locals: { search_term:, count: unpaginated_filtered_logs.size, post_path: email_csv_lettings_logs_path, codes_only: codes_only_export?, session_filters:, filter_type: "lettings_logs", download_csv_back_link: lettings_logs_path }
  end

  def email_csv
    all_orgs = params["organisation_select"] == "all"
    EmailCsvJob.perform_later(current_user, search_term, session_filters, all_orgs, nil, codes_only_export?, "lettings", session_filters["years"].first.to_i)
    redirect_to csv_confirmation_lettings_logs_path
  end

  def csv_confirmation; end

  def update_logs
    respond_to do |format|
      format.html do
        impacted_logs = current_user.lettings_logs.unresolved.assigned_to(current_user)

        @pagy, @logs = pagy(impacted_logs)
        @total_count = impacted_logs.size
        render "logs/update_logs"
      end
    end
  end

  def bulk_uploads
    return render_not_authorized unless current_user.support?

    @filter_type = "lettings_bulk_uploads"

    if params[:organisation_id].present? && params[:clear_old_filters].present?
      redirect_to clear_filters_path(filter_type: @filter_type, organisation_id: params[:organisation_id]) and return
    end

    uploads = BulkUpload.lettings.visible.where("created_at >= ?", 30.days.ago)
    unpaginated_filtered_uploads = filter_manager.filtered_uploads(uploads, search_term, filter_manager.session_filters)

    @pagy, @bulk_uploads = pagy(unpaginated_filtered_uploads)
    @search_term = search_term
    @total_count = uploads.size
    @searched = search_term.presence
    render "bulk_upload_shared/uploads"
  end

  def download_bulk_upload
    bulk_upload = BulkUpload.find(params[:id])
    downloader = BulkUpload::Downloader.new(bulk_upload:)

    if Rails.env.development?
      downloader.call
      send_file downloader.path, filename: bulk_upload.filename, type: "text/csv"
    else
      presigned_url = downloader.presigned_url
      redirect_to presigned_url, allow_other_host: true
    end
  end

private

  def session_filters
    filter_manager.session_filters
  end

  def filter_manager
    if request.path.include?("bulk-uploads")
      FilterManager.new(current_user:, session:, params:, filter_type: "lettings_bulk_uploads")
    else
      FilterManager.new(current_user:, session:, params:, filter_type: "lettings_logs")
    end
  end

  def authenticate_scope!
    head :unauthorized and return if codes_only_export? && !current_user.support?
  end

  def redirect_if_bulk_upload_resolved
    if @bulk_upload&.lettings? && @bulk_upload.lettings_logs.in_progress.count.zero?
      redirect_to resume_bulk_upload_lettings_result_path(@bulk_upload)
    end
  end

  def extract_bulk_upload_from_session_filters
    @bulk_upload = filter_manager.bulk_upload
  end

  def permitted_log_params
    params.require(:lettings_log).permit(LettingsLog.editable_fields)
  end

  def find_resource
    @log = LettingsLog.visible.find_by(id: params[:id])
  end

  def post_create_redirect_url(log)
    lettings_log_url(log)
  end

  def resolve_logs!
    if @log&.unresolved && @log.location.present? && @log.scheme.present? && @log&.resolve!
      unresolved_logs_count_for_user = current_user.lettings_logs.unresolved.assigned_to(current_user).count
      flash.now[:notice] = helpers.flash_notice_for_resolved_logs(unresolved_logs_count_for_user)
    end
  end
end
