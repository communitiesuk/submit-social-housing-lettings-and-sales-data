class AddOldIdAndIndexToCaseLogs < ActiveRecord::Migration[7.0]
  def change
    change_table :case_logs, bulk: true do |t|
      t.column :old_id, :string
    end
    add_index :case_logs, :old_id, unique: true
  end
end
