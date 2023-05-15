class AddDiscardedAtToLogs < ActiveRecord::Migration[7.0]
  def change
    add_column :sales_logs, :discarded_at, :datetime
    add_column :lettings_logs, :discarded_at, :datetime
  end
end
