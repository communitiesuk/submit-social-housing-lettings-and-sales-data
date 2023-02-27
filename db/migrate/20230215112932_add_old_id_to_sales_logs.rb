class AddOldIdToSalesLogs < ActiveRecord::Migration[7.0]
  def change
    change_table :sales_logs, bulk: true do |t|
      t.column :old_id, :string
    end
    add_index :sales_logs, :old_id, unique: true
  end
end
