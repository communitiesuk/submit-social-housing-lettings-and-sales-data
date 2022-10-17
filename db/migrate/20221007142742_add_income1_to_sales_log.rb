class AddIncome1ToSalesLog < ActiveRecord::Migration[7.0]
  change_table :sales_logs, bulk: true do |t|
    t.column :income1, :int
    t.column :income1nk, :int
  end
end
