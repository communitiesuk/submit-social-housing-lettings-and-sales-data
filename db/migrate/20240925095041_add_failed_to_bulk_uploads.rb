class AddFailedToBulkUploads < ActiveRecord::Migration[7.0]
  def change
    add_column :bulk_uploads, :failed, :integer
  end
end
