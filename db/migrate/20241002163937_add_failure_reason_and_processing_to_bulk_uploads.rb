class AddFailureReasonAndProcessingToBulkUploads < ActiveRecord::Migration[7.0]
  def change
    add_column :bulk_uploads, :failure_reason, :string
    add_column :bulk_uploads, :processing, :boolean
  end
end
