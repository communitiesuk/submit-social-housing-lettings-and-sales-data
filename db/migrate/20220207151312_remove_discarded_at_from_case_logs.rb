class RemoveDiscardedAtFromCaseLogs < ActiveRecord::Migration[7.0]
  def up
    remove_index :case_logs, :discarded_at
    remove_column :case_logs, :discarded_at
  end

  def down
    add_column :case_logs, :discarded_at, :datetime
    add_index :case_logs, :discarded_at
  end
end
