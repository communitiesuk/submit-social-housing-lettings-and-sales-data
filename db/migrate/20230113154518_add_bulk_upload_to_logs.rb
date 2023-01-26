class AddBulkUploadToLogs < ActiveRecord::Migration[7.0]
  def change
    add_reference :lettings_logs, :bulk_upload
    add_reference :sales_logs, :bulk_upload
  end
end
