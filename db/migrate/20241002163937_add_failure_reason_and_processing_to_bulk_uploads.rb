class AddFailureReasonAndProcessingToBulkUploads < ActiveRecord::Migration[7.0]
  def change
    change_table :bulk_uploads, bulk: true do |t|
      t.string :failure_reason
      t.boolean :processing
    end
  end
end
