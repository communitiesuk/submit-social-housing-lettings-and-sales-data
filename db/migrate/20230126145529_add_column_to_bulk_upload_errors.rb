class AddColumnToBulkUploadErrors < ActiveRecord::Migration[7.0]
  def change
    add_column :bulk_upload_errors, :col, :text
  end
end
