class AddServiceChargeChangedToSalesLogs < ActiveRecord::Migration[7.2]
  def change
    add_column :sales_logs, :hasservicechargeschanged, :integer
    add_column :sales_logs, :newservicecharges, :decimal, precision: 10, scale: 2
  end
end
