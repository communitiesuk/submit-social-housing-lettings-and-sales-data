class AddCategoryToBulkUploadErrors < ActiveRecord::Migration[7.0]
  def change
    add_column :bulk_upload_errors, :category, :text, null: true
  end
end
