class AddServiceChargeChangedToSalesLogs < ActiveRecord::Migration[7.2]
  def change
    change_table :sales_logs, bulk: true do |t|
      t.column :hasservicechargeschanged, :integer
      t.column :newservicecharges, :decimal, precision: 10, scale: 2
    end
  end
end
