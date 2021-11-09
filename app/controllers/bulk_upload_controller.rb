class BulkUploadController < ApplicationController
  SPREADSHEET_CONTENT_TYPES = %w[
    application/vnd.ms-excel
    application/vnd.openxmlformats-officedocument.spreadsheetml.sheet
  ]

  FIRST_DATA_ROW = 7

  def show
    render "case_logs/bulk_upload"
  end

  def process_bulk_upload
    if SPREADSHEET_CONTENT_TYPES.include?(params["case_log_bulk_upload"].content_type)
      xlsx = Roo::Spreadsheet.open(params["case_log_bulk_upload"].tempfile, extension: :xlsx)
      sheet = xlsx.sheet(0)
      last_row = sheet.last_row
      if last_row < FIRST_DATA_ROW
        head :no_content
      else
        data_range = FIRST_DATA_ROW..last_row
        data_range.map do |row_num|
          row = sheet.row(row_num)
          CaseLog.create!(
            tenant_code: row[7],
            startertenancy: row[8]
          )
        end
        redirect_to(case_logs_path)
      end
    end
  end
end
