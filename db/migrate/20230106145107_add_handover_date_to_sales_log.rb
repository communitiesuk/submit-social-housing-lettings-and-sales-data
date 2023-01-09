class AddHandoverDateToSalesLog < ActiveRecord::Migration[7.0]
  change_table :sales_logs, bulk: true do |t|
    t.column :hodate, :datetime
    t.column :hoday, :integer
    t.column :homonth, :integer
    t.column :hoyear, :integer
  end
end
