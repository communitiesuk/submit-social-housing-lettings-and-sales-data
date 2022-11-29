class AddBuyer2ToSales < ActiveRecord::Migration[7.0]
  change_table :sales_logs, bulk: true do |t|
    t.column :income2, :int
    t.column :income2nk, :int
  end
end
