class AddDiscardedAtToCaseLogs < ActiveRecord::Migration[6.1]
  def change
    add_column :case_logs, :discarded_at, :datetime
    add_index :case_logs, :discarded_at
  end
end
