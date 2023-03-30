class RemoveUnusedBulkUploadFields < ActiveRecord::Migration[7.0]
  def change
    change_table :bulk_uploads, bulk: true do |t|
      t.remove :processed, type: :boolean
      t.remove :expected_log_count, type: :integer
    end
  end
end
