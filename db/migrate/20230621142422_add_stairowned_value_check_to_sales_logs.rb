class AddStairownedValueCheckToSalesLogs < ActiveRecord::Migration[7.0]
  def change
    add_column :sales_logs, :stairowned_value_check, :integer
  end
end
