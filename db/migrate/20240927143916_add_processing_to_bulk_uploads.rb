class AddProcessingToBulkUploads < ActiveRecord::Migration[7.0]
  def change
    add_column :bulk_uploads, :processing, :boolean, default: false
  end
end
