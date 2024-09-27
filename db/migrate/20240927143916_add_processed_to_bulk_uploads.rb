class AddProcessedToBulkUploads < ActiveRecord::Migration[7.0]
  def change
    add_column :bulk_uploads, :processed, :boolean
  end
end
