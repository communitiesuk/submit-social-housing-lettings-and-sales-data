class AddBackgroundToSalesLog < ActiveRecord::Migration[7.0]
  change_table :sales_logs, bulk: true do |t|
    t.column :ethnic, :integer
    t.column :ethnic_group, :integer
  end
end
