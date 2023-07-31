class BulkUploadLettingsResultsController < ApplicationController
  before_action :authenticate_user!

  rescue_from ActiveRecord::RecordNotFound, with: :render_not_found

  def show
    @bulk_upload = BulkUpload.lettings.find(params[:id])

    authorize @bulk_upload
  end

  def resume
    @bulk_upload = BulkUpload.lettings.find(params[:id])

    authorize @bulk_upload

    if @bulk_upload.lettings_logs.in_progress.count.positive?
      set_bulk_upload_logs_filters

      redirect_to(lettings_logs_path(bulk_upload_id: [@bulk_upload.id]))
    else
      @bulk_upload.update!(choice: "completed")
      reset_logs_filters
    end
  end

  def summary
    @bulk_upload = BulkUpload.lettings.find(params[:id])

    authorize @bulk_upload
  end

private

  def reset_logs_filters
    session["logs_filters"] = {}.to_json
  end

  def set_bulk_upload_logs_filters
    hash = {
      years: [""],
      status: ["", "in_progress"],
      user: "all",
    }

    session["logs_filters"] = hash.to_json
  end
end
