class AddAge1ToSalesLogs < ActiveRecord::Migration[7.0]
  def change
    change_table :sales_logs, bulk: true do |t|
      t.column :age1, :integer
      t.column :age1_known, :integer
    end
  end
end
