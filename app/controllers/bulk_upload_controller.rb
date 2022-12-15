class BulkUploadController < ApplicationController
  before_action :authenticate_user!

  def show
    @bulk_upload = LegacyBulkUpload.new(nil, nil)
    render "logs/bulk_upload"
  end

  def bulk_upload
    file = upload_params.tempfile
    content_type = upload_params.content_type
    @bulk_upload = LegacyBulkUpload.new(file, content_type)
    @bulk_upload.process(current_user)
    if @bulk_upload.errors.present?
      render "logs/bulk_upload", status: :unprocessable_entity
    else
      redirect_to(lettings_logs_path)
    end
  end

private

  def upload_params
    params.require("bulk_upload")["lettings_log_bulk_upload"]
  end
end
