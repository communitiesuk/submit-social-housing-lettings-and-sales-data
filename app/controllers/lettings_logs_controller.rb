class LettingsLogsController < LogsController
  before_action :find_resource, except: %i[create index edit]

  def index
    set_session_filters

    all_logs = current_user.lettings_logs
    unpaginated_filtered_logs = filtered_logs(filtered_collection(all_logs, search_term))

    respond_to do |format|
      format.html do
        @pagy, @lettings_logs = pagy(unpaginated_filtered_logs)
        @searched = search_term.presence
        @total_count = all_logs.size
      end

      format.csv do
        send_data byte_order_mark + unpaginated_filtered_logs.to_csv(current_user), filename: "logs-#{Time.zone.now}.csv"
      end
    end
  end

  def create
    super { LettingsLog.new(log_params) }
  end

  def update
    if @lettings_log
      if @lettings_log.update(api_log_params)
        render json: @lettings_log, status: :ok
      else
        render json: { errors: @lettings_log.errors.messages }, status: :unprocessable_entity
      end
    else
      render_not_found_json("Log", params[:id])
    end
  end

  def show
    respond_to do |format|
      # We don't have a dedicated non-editable show view
      format.html { edit }
      format.json do
        if @lettings_log
          render json: @lettings_log, status: :ok
        else
          render_not_found_json("Log", params[:id])
        end
      end
    end
  end

  def edit
    @lettings_log = current_user.lettings_logs.find_by(id: params[:id])
    if @lettings_log
      render :edit, locals: { current_user: }
    else
      render_not_found
    end
  end

  def destroy
    if @lettings_log
      if @lettings_log.delete
        head :no_content
      else
        render json: { errors: @lettings_log.errors.messages }, status: :unprocessable_entity
      end
    else
      render_not_found_json("Log", params[:id])
    end
  end

private

  def permitted_log_params
    params.require(:lettings_log).permit(LettingsLog.editable_fields)
  end

  def find_resource
    @lettings_log = LettingsLog.find_by(id: params[:id])
  end

  def post_create_redirect_url(log)
    lettings_log_url(log)
  end
end
