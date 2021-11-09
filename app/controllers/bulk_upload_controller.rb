class BulkUploadController < ApplicationController
  XLS = "application/vnd.ms-excel".freeze

  def show
    render "case_logs/bulk_upload"
  end

  def process_bulk_upload
    if params["case_log_bulk_upload"].content_type == XLS
      xlsx = Roo::Spreadsheet.open(params["case_log_bulk_upload"].tempfile, extension: :xlsx)
    end
  end
end
