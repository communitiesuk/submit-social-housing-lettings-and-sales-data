class AddTotalLogsCountToBulkUpload < ActiveRecord::Migration[7.0]
  def change
    add_column :bulk_uploads, :total_logs_count, :integer
  end
end
