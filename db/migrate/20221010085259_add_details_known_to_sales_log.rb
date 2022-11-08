class AddDetailsKnownToSalesLog < ActiveRecord::Migration[7.0]
  change_table :sales_logs, bulk: true do |t|
    t.column :details_known_2, :integer
    t.column :details_known_3, :integer
    t.column :details_known_4, :integer
  end
end
