class BulkUploadLettingsResultsController < ApplicationController
  before_action :authenticate_user!

  rescue_from ActiveRecord::RecordNotFound, with: :render_not_found

  def show
    @bulk_upload = current_user.bulk_uploads.lettings.find(params[:id])
  end

  def resume
    @bulk_upload = current_user.bulk_uploads.lettings.find(params[:id])

    set_bulk_upload_logs_filters

    redirect_to(lettings_logs_path(bulk_upload_id: [@bulk_upload.id]))
  end

private

  def set_bulk_upload_logs_filters
    hash = {
      years: [""],
      status: ["", "in_progress"],
      user: "all",
    }

    session["logs_filters"] = hash.to_json
  end
end
