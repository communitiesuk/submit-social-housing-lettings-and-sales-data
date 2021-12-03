class BulkUploadController < ApplicationController
  before_action :authenticate_user!

  def show
    @bulk_upload = BulkUpload.new(nil, nil)
    render "case_logs/bulk_upload"
  end

  def bulk_upload
    file = upload_params.tempfile
    content_type = upload_params.content_type
    @bulk_upload = BulkUpload.new(file, content_type)
    @bulk_upload.process
    if @bulk_upload.errors.present?
      render "case_logs/bulk_upload", status: :unprocessable_entity
    else
      redirect_to(case_logs_path)
    end
  end

private

  def upload_params
    params.require("bulk_upload")["case_log_bulk_upload"]
  end
end
