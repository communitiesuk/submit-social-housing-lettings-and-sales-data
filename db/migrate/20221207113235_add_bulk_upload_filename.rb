class AddBulkUploadFilename < ActiveRecord::Migration[7.0]
  def change
    add_column :bulk_uploads, :filename, :text
  end
end
